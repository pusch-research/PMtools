function struct2ws(s,varargin)

% struct2ws(s,varargin)
%
% Description : This function returns fields of scalar structure s in the
% current workspace
% __________________________________
% Inputs : 
%   s (scalar structure array) :    a structure that you want to throw in
%                                   your current workspace.
%   re (string optional) :          a regular expression. Only fields
%                                   matching re will be returned
% Outputs :
%   No output : variables are thrown directly in the caller workspace.
%
% Examples :
% 
%   Example 1:
%     >> who
% 
%     Your variables are:
% 
%     params  
% 
%      >>struct2ws(params)
%      >> who
% 
%     Your variables are:
% 
%     blanc         grille        ratio_ecran   unitX         
%     c_map         gris          rect          unitY         
%     centre        magni_jitt    taille        window        
%     dim_grille    noir          taille_cr     zoomzoom      
%     epais_cr      params        taille_items  
%
%   Example 2:
%     >> struct2ws(params,'unit')
%     >> who
% 
%     Your variables are:
% 
%     params  unitX   unitY   
% 
%
% _____________________________________
% See also : ws2struct ; regexp
%
% Maximilien Chaumon v1.0 02/2007


if nargin == 0
    cd('d:\Bureau\work')
    s = dir('pathdef.m');
end
if length(s) > 1
    error('Structure should be scalar.');
end
if not(isempty(varargin))
    re = varargin{1};
else
    re = '.*';
end

vars = fieldnames(s);
vmatch = regexp(vars,re);
varsmatch = [];
for i = 1:length(vmatch)
    if isempty(vmatch{i})
        continue
    end
    varsmatch(end+1) = i;
end
for i = varsmatch
    assignin('caller',vars{i},s.(vars{i}));
end

