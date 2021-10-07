% XCOLORMAP returns colors from map
%   
%   J=XCOLORMAP(CMAP)
%   J=XCOLORMAP(CMAP,M)
%   J=XCOLORMAP(CMAP,M,INTERPMETHOD)
%   J=XCOLORMAP(CMAP,M,INTERPMETHOD,N_MIN)
%   for a color map function handle CMAP, a color array J of size
%   a) [M 3]        for M scalar
%                   (lineary spaced colors)
%   b) [numel(M) 3] for M numeric array
%                   (interpolated colors according to the values in M)
%   is returned.
%   
%   Example: XCOLORMAP(@jet,[1 2 10])
%       
%   See also COLORMAP,JET,PARULA,INTERP1

% REVISIONS:    2016-10-07 first implementation (MP)
% 
% Contact       pusch.research@gmail.com
%
function J=xcolormap(cmap,m,interpMethod,n_min)

if nargin<2
    
    J=cmap();
    
elseif isscalar(m)
    
    J=cmap(m);
    
else
    
    d_min=min(abs(diff(m(:))));

    if d_min>0
        
        if nargin<4 || isempty(n_min)
            n_min=64; % minimum number of colors for interpolation (typical size of colorbar in figure)
        end
        if nargin<3 || isempty(interpMethod)
            interpMethod='linear';
        end
        
        m_min=min(m(:));
        m_max=max(m(:));
        n=max(floor((m_max-m_min)/d_min)+2,n_min);
        if n>1e5
            n=1e5;
        end
        J=cmap(n);
        
        % interpolate colors for given values
        J=interp1(linspace(m_min,m_max,n)',J,m,interpMethod);
        
    else
        J=repmat(cmap(1),numel(m),1);
    end
    
end