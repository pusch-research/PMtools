function parsave(varargin)
savefile = varargin{1}; % first input argument
for ii=2:2:nargin-1
    savevar.(varargin{ii}) = varargin{ii+1}; % other input arguments
end
save(savefile,'-struct','savevar')