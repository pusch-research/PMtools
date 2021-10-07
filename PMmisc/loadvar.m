function varargout=loadvar(fileName,varName,varargin)
% load a single variable from .mat file



if iscell(varName)
    data=load(fileName,varName{:},varargin{:});
    for ii=numel(varName):-1:1
       varargout{ii}=data.(varName{ii});
    end
else
    data=load(fileName,varName,varargin{:});
    varargout{1}=data.(varName);
end