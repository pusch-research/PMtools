% function lineStyles = linspecer(N)
% This function creates an Nx3 array of N [R B G] colors
% These can be used to plot lots of lines with distinguishable and nice
% looking colors.
% 
% lineStyles = linspecer(N);  makes N colors for you to use: lineStyles(ii,:)
% 
% colormap(linspecer); set your colormap to have easily distinguishable 
%                      colors and a pleasing aesthetic
% 
% lineStyles = linspecer(N,'qualitative'); forces the colors to all be distinguishable (up to 12)
% lineStyles = linspecer(N,'sequential'); forces the colors to vary along a spectrum 
% 
% % Examples demonstrating the colors.
% 
% LINE COLORS
% N=6;
% X = linspace(0,pi*3,1000); 
% Y = bsxfun(@(x,n)sin(x+2*n*pi/N), X.', 1:N); 
% C = linspecer(N);
% axes('NextPlot','replacechildren', 'ColorOrder',C);
% plot(X,Y,'linewidth',5)
% ylim([-1.1 1.1]);
% 
% SIMPLER LINE COLOR EXAMPLE
% N = 6; X = linspace(0,pi*3,1000);
% C = linspecer(N)
% hold off;
% for ii=1:N
%     Y = sin(X+2*ii*pi/N);
%     plot(X,Y,'color',C(ii,:),'linewidth',3);
%     hold on;
% end
% 
% COLORMAP EXAMPLE
% A = rand(15);
% figure; imagesc(A); % default colormap
% figure; imagesc(A); colormap(linspecer); % linspecer colormap
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% by Jonathan Lansey, March 2009-2013 – Lansey at gmail.com               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%% credits and where the function came from
% The colors are largely taken from:
% http://colorbrewer2.org and Cynthia Brewer, Mark Harrower and The Pennsylvania State University
% 
% 
% She studied this from a phsychometric perspective and crafted the colors
% beautifully.
% 
% I made choices from the many there to decide the nicest once for plotting
% lines in Matlab. I also made a small change to one of the colors I
% thought was a bit too bright. In addition some interpolation is going on
% for the sequential line styles.
% 
% 
%%

function lineStyles=linspecer(N,varargin)

% % default line map from matlab 2014b                                       15-06-19 pusch.research@gmail.com
% if isempty(varargin)
%     cmap=[0 0.447 0.741;0.85 0.325 0.098;0.929 0.694 0.125;0.494 0.184 0.556;0.466 0.674 0.188;0.301 0.745 0.933;0.635 0.078 0.184;0 0.447 0.741;0.85 0.325 0.098;0.929 0.694 0.125;0.494 0.184 0.556;0.466 0.674 0.188;0.301 0.745 0.933;0.635 0.078 0.184;0 0.447 0.741;0.85 0.325 0.098;0.929 0.694 0.125;0.494 0.184 0.556;0.466 0.674 0.188;0.301 0.745 0.933;0.635 0.078 0.184;0 0.447 0.741;0.85 0.325 0.098;0.929 0.694 0.125;0.494 0.184 0.556;0.466 0.674 0.188;0.301 0.745 0.933;0.635 0.078 0.184;0 0.447 0.741;0.85 0.325 0.098;0.929 0.694 0.125;0.494 0.184 0.556;0.466 0.674 0.188;0.301 0.745 0.933;0.635 0.078 0.184;0 0.447 0.741;0.85 0.325 0.098;0.929 0.694 0.125;0.494 0.184 0.556;0.466 0.674 0.188;0.301 0.745 0.933;0.635 0.078 0.184;0 0.447 0.741;0.85 0.325 0.098;0.929 0.694 0.125;0.494 0.184 0.556;0.466 0.674 0.188;0.301 0.745 0.933;0.635 0.078 0.184;0 0.447 0.741;0.85 0.325 0.098;0.929 0.694 0.125;0.494 0.184 0.556;0.466 0.674 0.188;0.301 0.745 0.933;0.635 0.078 0.184;0 0.447 0.741;0.85 0.325 0.098;0.929 0.694 0.125;0.494 0.184 0.556;0.466 0.674 0.188;0.301 0.745 0.933;0.635 0.078 0.184;0 0.447 0.741];
%     lineStyles=cmap(1:N,:);
%     return;
% end

% % default line map from matlab 2014b first three elements swapped           15-06-19 pusch.research@gmail.com
% if isempty(varargin)
%     cmap=[0.929 0.694 0.125;0 0.447 0.741;0.85 0.325 0.098;0.494 0.184 0.556;0.466 0.674 0.188;0.301 0.745 0.933;0.635 0.078 0.184;0 0.447 0.741;0.85 0.325 0.098;0.929 0.694 0.125;0.494 0.184 0.556;0.466 0.674 0.188;0.301 0.745 0.933;0.635 0.078 0.184;0 0.447 0.741;0.85 0.325 0.098;0.929 0.694 0.125;0.494 0.184 0.556;0.466 0.674 0.188;0.301 0.745 0.933;0.635 0.078 0.184;0 0.447 0.741;0.85 0.325 0.098;0.929 0.694 0.125;0.494 0.184 0.556;0.466 0.674 0.188;0.301 0.745 0.933;0.635 0.078 0.184;0 0.447 0.741;0.85 0.325 0.098;0.929 0.694 0.125;0.494 0.184 0.556;0.466 0.674 0.188;0.301 0.745 0.933;0.635 0.078 0.184;0 0.447 0.741;0.85 0.325 0.098;0.929 0.694 0.125;0.494 0.184 0.556;0.466 0.674 0.188;0.301 0.745 0.933;0.635 0.078 0.184;0 0.447 0.741;0.85 0.325 0.098;0.929 0.694 0.125;0.494 0.184 0.556;0.466 0.674 0.188;0.301 0.745 0.933;0.635 0.078 0.184;0 0.447 0.741;0.85 0.325 0.098;0.929 0.694 0.125;0.494 0.184 0.556;0.466 0.674 0.188;0.301 0.745 0.933;0.635 0.078 0.184;0 0.447 0.741;0.85 0.325 0.098;0.929 0.694 0.125;0.494 0.184 0.556;0.466 0.674 0.188;0.301 0.745 0.933;0.635 0.078 0.184;0 0.447 0.741];
%     lineStyles=cmap(1:N,:);
%     return;
% end


if nargin==0 % return a colormap
    lineStyles = linspecer(64);
%     temp = [temp{:}];
%     lineStyles = reshape(temp,3,255)';
    return;
end

if N<=0 % its empty, nothing else to do here
    lineStyles=[];
    return;
end

% interperet varagin
qualFlag = 0;

if ~isempty(varargin)>0 % you set a parameter?
    switch lower(varargin{1})
        case {'qualitative','qua'}
            if N>7
                warning('qualitiative is not possible for greater than 7 items, please reconsider');
            end
            lineStyles=cmapsLOCAL('lines');
            lineStyles=lineStyles(1:N,:);
            return %15-10-19 pusch.research@gmail.com
        case {'default'}
            if N>12 % go home, you just can't get this.
                warning('qualitiative is not possible for greater than 12 items, please reconsider');
            else
                if N>9
                    warning(['Default may be nicer for ' num2str(N) ' for clearer colors use: whitebg(''black''); ']);
                end
            end
            qualFlag = 1;
        case {'sequential','seq'}
            lineStyles = colorm(N);
            return;
        otherwise
            color_arr=colormap(varargin{1});
            if ~isempty(N)
                n_color=size(color_arr,1);
                lineStyles=color_arr(round((N+1-(1:N))/N*n_color),:);
            end
            return;
    end
end      
      
% predefine some colormaps
  set3 = colorBrew2mat({[141, 211, 199];[ 255, 237, 111];[ 190, 186, 218];[ 251, 128, 114];[ 128, 177, 211];[ 253, 180, 98];[ 179, 222, 105];[ 188, 128, 189];[ 217, 217, 217];[ 204, 235, 197];[ 252, 205, 229];[ 255, 255, 179]}');
set1JL = brighten(colorBrew2mat({[228, 26, 28];[ 55, 126, 184];[ 77, 175, 74];[ 255, 127, 0];[ 255, 237, 111]*.95;[ 166, 86, 40];[ 247, 129, 191];[ 153, 153, 153];[ 152, 78, 163]}'));
set1 = brighten(colorBrew2mat({[ 55, 126, 184]*.95;[228, 26, 28];[ 77, 175, 74];[ 255, 127, 0];[ 152, 78, 163]}),.8);

set3 = dim(set3,.93);

switch N
    case 1
        lineStyles = { [  55, 126, 184]/255};
    case {2, 3, 4, 5 }
        lineStyles = set1(1:N);
    case {6 , 7, 8, 9}
        lineStyles = set1JL(1:N)';
    case {10, 11, 12}
        if qualFlag % force qualitative graphs
            lineStyles = set3(1:N)';
        else % 10 is a good number to start with the sequential ones.
            lineStyles = cmap2linspecer(colorm(N));
        end
otherwise % any old case where I need a quick job done.
    lineStyles = cmap2linspecer(colorm(N));
end
lineStyles = cell2mat(lineStyles);
end

% extra functions
function varIn = colorBrew2mat(varIn)
for ii=1:length(varIn) % just divide by 255
    varIn{ii}=varIn{ii}/255;
end        
end

function varIn = brighten(varIn,varargin) % increase the brightness

if isempty(varargin),
    frac = .9; 
else
    frac = varargin{1}; 
end

for ii=1:length(varIn)
    varIn{ii}=varIn{ii}*frac+(1-frac);
end        
end

function varIn = dim(varIn,f)
    for ii=1:length(varIn)
        varIn{ii} = f*varIn{ii};
    end
end

function vOut = cmap2linspecer(vIn) % changes the format from a double array to a cell array with the right format
vOut = cell(size(vIn,1),1);
for ii=1:size(vIn,1)
    vOut{ii} = vIn(ii,:);
end
end
%%
% colorm returns a colormap which is really good for creating informative
% heatmap style figures.
% No particular color stands out and it doesn't do too badly for colorblind people either.
% It works by interpolating the data from the
% 'spectral' setting on http://colorbrewer2.org/ set to 11 colors
% It is modified a little to make the brightest yellow a little less bright.
function cmap = colorm(varargin)
n = 100;
if ~isempty(varargin)
    n = varargin{1};
end

if n==1
    cmap =  [0.2005    0.5593    0.7380];
    return;
end
if n==2
     cmap =  [0.2005    0.5593    0.7380;
              0.9684    0.4799    0.2723];
          return;
end

frac=.95; % Slight modification from colorbrewer here to make the yellows in the center just a bit darker
cmapp = [158, 1, 66; 213, 62, 79; 244, 109, 67; 253, 174, 97; 254, 224, 139; 255*frac, 255*frac, 191*frac; 230, 245, 152; 171, 221, 164; 102, 194, 165; 50, 136, 189; 94, 79, 162];
x = linspace(1,n,size(cmapp,1));
xi = 1:n;
cmap = zeros(n,3);
for ii=1:3
    cmap(:,ii) = pchip(x,cmapp(:,ii),xi);
end
cmap = flipud(cmap/255);
end



function cmap = cmapsLOCAL(name)

switch name
    case 'parula'
        cmap=...
        [      0.2081       0.1663       0.5292
              0.21162      0.18978      0.57768
              0.21225      0.21377      0.62697
               0.2081       0.2386      0.67709
               0.1959      0.26446       0.7279
              0.17073      0.29194      0.77925
              0.12527      0.32424      0.83027
             0.059133      0.35983      0.86833
             0.011695      0.38751      0.88196
            0.0059571      0.40861      0.88284
             0.016514       0.4266      0.87863
             0.032852      0.44304      0.87196
             0.049814      0.45857      0.86406
             0.062933      0.47369      0.85544
             0.072267      0.48867       0.8467
             0.077943      0.50399      0.83837
             0.079348      0.52002      0.83118
             0.074943      0.53754      0.82627
             0.064057      0.55699      0.82396
             0.048771      0.57722      0.82283
             0.034343      0.59658      0.81985
               0.0265       0.6137       0.8135
              0.02389      0.62866      0.80376
              0.02309      0.64179      0.79127
             0.022771      0.65349      0.77676
             0.026662       0.6642      0.76072
             0.038371      0.67427      0.74355
             0.058971      0.68376      0.72539
               0.0843      0.69283      0.70617
               0.1133       0.7015      0.68586
              0.14527      0.70976      0.66463
              0.18013      0.71766      0.64243
              0.21783      0.72504      0.61926
              0.25864      0.73171      0.59543
              0.30217       0.7376      0.57119
              0.34817      0.74243      0.54727
              0.39526       0.7459      0.52444
              0.44201      0.74808      0.50331
              0.48712      0.74906      0.48398
              0.53003      0.74911      0.46611
              0.57086      0.74852      0.44939
              0.60985      0.74731      0.43369
               0.6473       0.7456       0.4188
              0.68342      0.74348      0.40443
              0.71841      0.74113      0.39048
              0.75249       0.7384      0.37681
              0.78584      0.73557      0.36327
               0.8185      0.73273      0.34979
              0.85066       0.7299      0.33603
              0.88243      0.72743       0.3217
              0.91393      0.72579      0.30628
              0.94496      0.72611      0.28864
               0.9739       0.7314      0.26665
              0.99377      0.74546      0.24035
              0.99904      0.76531      0.21641
              0.99553      0.78606      0.19665
                0.988       0.8066      0.17937
              0.97886      0.82714      0.16331
               0.9697      0.84814      0.14745
              0.96259      0.87051       0.1309
              0.95887       0.8949      0.11324
              0.95982      0.92183     0.094838
               0.9661      0.95144     0.075533
               0.9763       0.9831       0.0538];
    case 'jet'
        cmap=...
        [           0            0       0.5625
                    0            0        0.625
                    0            0       0.6875
                    0            0         0.75
                    0            0       0.8125
                    0            0        0.875
                    0            0       0.9375
                    0            0            1
                    0       0.0625            1
                    0        0.125            1
                    0       0.1875            1
                    0         0.25            1
                    0       0.3125            1
                    0        0.375            1
                    0       0.4375            1
                    0          0.5            1
                    0       0.5625            1
                    0        0.625            1
                    0       0.6875            1
                    0         0.75            1
                    0       0.8125            1
                    0        0.875            1
                    0       0.9375            1
                    0            1            1
               0.0625            1       0.9375
                0.125            1        0.875
               0.1875            1       0.8125
                 0.25            1         0.75
               0.3125            1       0.6875
                0.375            1        0.625
               0.4375            1       0.5625
                  0.5            1          0.5
               0.5625            1       0.4375
                0.625            1        0.375
               0.6875            1       0.3125
                 0.75            1         0.25
               0.8125            1       0.1875
                0.875            1        0.125
               0.9375            1       0.0625
                    1            1            0
                    1       0.9375            0
                    1        0.875            0
                    1       0.8125            0
                    1         0.75            0
                    1       0.6875            0
                    1        0.625            0
                    1       0.5625            0
                    1          0.5            0
                    1       0.4375            0
                    1        0.375            0
                    1       0.3125            0
                    1         0.25            0
                    1       0.1875            0
                    1        0.125            0
                    1       0.0625            0
                    1            0            0
               0.9375            0            0
                0.875            0            0
               0.8125            0            0
                 0.75            0            0
               0.6875            0            0
                0.625            0            0
               0.5625            0            0
                  0.5            0            0];
    case {'lines','qualitative'}
        cmap=...
            [       0        0.447        0.741
                 0.85        0.325        0.098
                0.929        0.694        0.125
                0.494        0.184        0.556
                0.466        0.674        0.188
                0.301        0.745        0.933
                0.635        0.078        0.184
                    0        0.447        0.741
                 0.85        0.325        0.098
                0.929        0.694        0.125
                0.494        0.184        0.556
                0.466        0.674        0.188
                0.301        0.745        0.933
                0.635        0.078        0.184
                    0        0.447        0.741
                 0.85        0.325        0.098
                0.929        0.694        0.125
                0.494        0.184        0.556
                0.466        0.674        0.188
                0.301        0.745        0.933
                0.635        0.078        0.184
                    0        0.447        0.741
                 0.85        0.325        0.098
                0.929        0.694        0.125
                0.494        0.184        0.556
                0.466        0.674        0.188
                0.301        0.745        0.933
                0.635        0.078        0.184
                    0        0.447        0.741
                 0.85        0.325        0.098
                0.929        0.694        0.125
                0.494        0.184        0.556
                0.466        0.674        0.188
                0.301        0.745        0.933
                0.635        0.078        0.184
                    0        0.447        0.741
                 0.85        0.325        0.098
                0.929        0.694        0.125
                0.494        0.184        0.556
                0.466        0.674        0.188
                0.301        0.745        0.933
                0.635        0.078        0.184
                    0        0.447        0.741
                 0.85        0.325        0.098
                0.929        0.694        0.125
                0.494        0.184        0.556
                0.466        0.674        0.188
                0.301        0.745        0.933
                0.635        0.078        0.184
                    0        0.447        0.741
                 0.85        0.325        0.098
                0.929        0.694        0.125
                0.494        0.184        0.556
                0.466        0.674        0.188
                0.301        0.745        0.933
                0.635        0.078        0.184
                    0        0.447        0.741
                 0.85        0.325        0.098
                0.929        0.694        0.125
                0.494        0.184        0.556
                0.466        0.674        0.188
                0.301        0.745        0.933
                0.635        0.078        0.184
                    0        0.447        0.741];
    otherwise
        error('not implemented');
end
end
