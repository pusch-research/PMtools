function [output,status,headers] = xurlread(urlChar,method,params,headers)
% XURLREAD Returns the contents of a URL as a string including headers
%
%   XURLREAD is an extension to the standard Matlab function URLREAD. It
%   also accepts and returns header fields.
%
%   S = XURLREAD('URL') reads the content at a URL into a string, S.  If the
%   server returns binary data, the string will contain garbage.
%
%   S = XURLREAD('URL','method',PARAMS) passes information to the server as
%   part of the request.  The 'method' can be 'get', or 'post' and PARAMS is a 
%   cell array of param/value pairs.
%
%   S = XURLREAD('URL','method',PARAMS,HEADERS) adds the given header
%   fields to the request. This is particularly useful to return a Cookie
%   to a server. HEADERS is a cell array of param/value pairs.
%
%   [S,STATUS] = URLREAD(...) catches any errors and returns 1 if the file
%   downloaded successfully and 0 otherwise.
%
%   [S,STATUS,HEADERS] = URLREAD(...) returns a cell array HEADERS with the
%   header fields sent by the server. HEADERS is a cell array of
%   param/value pairs.
%
%   Examples:
%   s = urlread('http://www.mathworks.com')
%   s = urlread('ftp://ftp.mathworks.com/README')
%   s = urlread(['file:///' fullfile(prefdir,'history.m')])
% 
%   From behind a firewall, use the Preferences to set your proxy server.
%
%   See also URLREAD, URLWRITE

%   Matthew J. Simoneau, 13-Nov-2001
%   Copyright 1984-2006 The MathWorks, Inc.
%   $Revision: 1.3.2.8 $ $Date: 2006/12/20 07:16:57 $
%
% Contact       pusch.research@gmail.com
%

% This function requires Java.
if ~usejava('jvm')
   error('MATLAB:urlread:NoJvm','URLREAD requires Java.');
end

import com.mathworks.mlwidgets.io.InterruptibleStreamCopier;

% Be sure the proxy settings are set.
com.mathworks.mlwidgets.html.HTMLPrefs.setProxySettings

% Check number of inputs and outputs.
narginchk(1,4)
nargoutchk(0,3)
if (nargin > 1) && ~strcmpi(method,'get') && ~strcmpi(method,'post')
    error('MATLAB:urlread:InvalidInput','Second argument must be either "get" or "post".');
end

% Do we want to throw errors or catch them?
if nargout == 2
    catchErrors = true;
else
    catchErrors = false;
end

% Set default outputs.
output = '';
status = 0;

% GET method.  Tack param/value to end of URL.
if (nargin > 1) && strcmpi(method,'get')
    if mod(length(params),2) == 1
        error('MATLAB:urlread:InvalidInput','Invalid parameter/value pair arguments.');
    end
    for i=1:2:length(params)
        if (i == 1), separator = '?'; else, separator = '&'; end
        param = char(java.net.URLEncoder.encode(params{i}));
        value = char(java.net.URLEncoder.encode(params{i+1}));
        urlChar = [urlChar separator param '=' value];
    end
end

% Create urlreadwrite handle
old_pwd  = pwd;
% cd([matlabroot '\toolbox\matlab\iofun\private']);
cd(fullfile (matlabroot,'toolbox','matlab','iofun','private'));
urlreadwrite_local = @urlreadwrite;

cd(old_pwd);

% Create a urlConnection.
urlreadwrite_local=@urlreadwrite_LOCAL; 
[urlConnection,errorid,errormsg] = urlreadwrite_local('urlread',urlChar);
if isempty(urlConnection)
    if catchErrors, return
    else error(errorid,errormsg);
    end
end

% Disable implicit redirects
urlConnection.setFollowRedirects(0)

% Set header fields
if nargin >= 4
    if mod(length(headers),2) == 1
        error('xurlread:InvalidInput','Invalid parameter/value pair arguments.');
    end
    for i=1:2:length(headers)
        urlConnection.setRequestProperty(headers{i}, headers{i+1});
    end
end    

% POST method.  Write param/values to server.
if (nargin > 1) && strcmpi(method,'post')
    try
        urlConnection.setDoOutput(true);
        urlConnection.setRequestProperty( ...
            'Content-Type','application/x-www-form-urlencoded');
        printStream = java.io.PrintStream(urlConnection.getOutputStream);
        for i=1:2:length(params)
            if (i > 1), printStream.print('&'); end
            param = char(java.net.URLEncoder.encode(params{i}));
            value = char(java.net.URLEncoder.encode(params{i+1}));
            printStream.print([param '=' value]);
        end
        printStream.close;
    catch
        if catchErrors, return
        else error('MATLAB:urlread:ConnectionFailed','Could not POST to URL.');
        end
    end
end

% Read the data from the connection.
try
    inputStream = urlConnection.getInputStream;
    byteArrayOutputStream = java.io.ByteArrayOutputStream;
    % This StreamCopier is unsupported and may change at any time.
    isc = InterruptibleStreamCopier.getInterruptibleStreamCopier;
    isc.copyStream(inputStream,byteArrayOutputStream);
    inputStream.close;
    byteArrayOutputStream.close;
    output = native2unicode(typecast(byteArrayOutputStream.toByteArray','uint8'),'UTF-8');
catch
    if catchErrors, return
    else error('MATLAB:urlread:ConnectionFailed','Error downloading URL.');
    end
end

% Read the header section of the response
headers_raw    = char(urlConnection.getHeaderFields);
headers_tokens = regexp(headers_raw, '([^\=\,\s\{])*?\s*\=\s*\[([^\]])+\]', 'tokens');
headers_out    = horzcat( cellfun(@(c)c{1}, headers_tokens, 'UniformOutput', false)' ...
                        , cellfun(@(c)c{2}, headers_tokens, 'UniformOutput', false)' ...
                        )';

% Follow redirects explicitly
location = headers_out(2, strcmpi(headers_out(1,:), 'Location'));
if ~isempty(location)
    location = location{1};
    switch nargin
        case 1
            [output,status,headers2] = xurlread(location);
        case 2
            [output,status,headers2] = xurlread(location,method);
        case 3
            [output,status,headers2] = xurlread(location,method,params);
        otherwise
            [output,status,headers2] = xurlread(location,method,params,headers);
    end
    for i = 1:size(headers2,2)
        pos = strcmpi(headers_out(1,:), headers2{1,i});
        if ~any(pos)
            headers_out(:,end+1) = headers2(:,i); %#ok<AGROW>
        elseif strcmpi(headers2{1,i}, 'set-cookie')
            headers_out{2,pos}   = [headers_out{2,pos} ', ' headers2{2,i}];
        else
            headers_out{2,pos}   =                          headers2{2,i} ;
        end
    end
end

% Set headers output
headers = headers_out;
                    
% Set status output to good, if reached here
status = 1;























function [urlConnection,errorid,errormsg] = urlreadwrite_LOCAL(fcn,urlChar)  
%URLREADWRITE A helper function for URLREAD and URLWRITE.

%   Matthew J. Simoneau, June 2005
%   Copyright 1984-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $ $Date: 2009/02/10 21:04:47 $

% Default output arguments.
urlConnection = [];
errorid = '';
errormsg = '';

% Determine the protocol (before the ":").
protocol = urlChar(1:min(find(urlChar==':'))-1);

% Try to use the native handler, not the ice.* classes.
switch protocol
    case 'http'
        try
            handler = sun.net.www.protocol.http.Handler;
        catch exception %#ok
            handler = [];
        end
    case 'https'
        try
            handler = sun.net.www.protocol.https.Handler;
        catch exception %#ok
            handler = [];
        end
    otherwise
        handler = [];
end

% Create the URL object.
try
    if isempty(handler)
        url = java.net.URL(urlChar);
    else
        url = java.net.URL([],urlChar,handler);
    end
catch exception %#ok
    errorid = ['MATLAB:' fcn ':InvalidUrl'];
    errormsg = 'Either this URL could not be parsed or the protocol is not supported.';
    return
end

% Get the proxy information using MathWorks facilities for unified proxy
% prefence settings.
mwtcp = com.mathworks.net.transport.MWTransportClientPropertiesFactory.create();
proxy = mwtcp.getProxy(); 


% Open a connection to the URL.
if isempty(proxy)
    urlConnection = url.openConnection;
else
    urlConnection = url.openConnection(proxy);
end

