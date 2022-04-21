function keep(varargin)
% KEEP Keeps the caller workspace variables of your choice and clears the rest.
%
%   Its usage is just like CLEAR but the command works only for variables
%   and not for functions etc.
%
%   KEEP MY_VAR clears all variables in the caller workspace except the 
%   variable MY_VAR.
%
%   See also: CLEAR CLEARVARS




%       Keep all
if isempty(varargin)
    return
end

% Only use this piece of code, if version is prior to 7.6
if ~any(exist('verLessThan') == [2 3 5 6]) || verLessThan('matlab','7.6.0')

    %       See what are in caller workspace
    wh = evalin('caller','who');


    %       Check workspace variables
    if isempty(wh)
        error('  There is nothing to keep!')
    end


    %       Construct a string containing workspace variables delimited by ":"
    variable = [];
    for i = 1:length(wh)
        variable = [variable,':',wh{i}];
    end
    variable = [variable,':'];


    %       Extract desired variables from string
    flag = 0;
    for i = 1:length(varargin)
        I = findstr(variable,[':',varargin{i},':']);
        if isempty(I)
            disp(['       ',varargin{i}, ' does not exist!'])
            flag = 1;
        elseif I == 1
            variable = variable(1+length(varargin{i})+1:length(variable));
        elseif I+length(varargin{i})+1 == length(variable)
            variable = variable(1:I);
        else
            variable = [variable(1:I),variable(I+length(varargin{i})+2:length(variable))];
        end
    end


    %       No delete if some input variables do not exist
    if flag == 1
        disp('       No variables are deleted!')
        return
    end


    %       Convert string back to cell and delete the rest
    I = findstr(variable,':');
    if length(I) ~= 1
        for i = 1:length(I)-1
            if i ~= length(I)-1
                del(i) = {[variable(I(i)+1:I(i+1)-1),' ']};
            else
                del(i) = {variable(I(i)+1:length(variable)-1)};
            end
        end
        evalin('caller',['clear ',del{:}])
    end

% Use this new MATLAB functionality for newer versions
else
    keepstring='';
    for i=1:length(varargin)
        keepstring = [keepstring, varargin{i},' '];
    end
    evalin('caller',['clearvars ','-except ', keepstring])
end