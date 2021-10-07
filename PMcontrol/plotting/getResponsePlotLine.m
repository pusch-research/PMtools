% GETRESPONSEPLOTLINE 
%   
%   HLINEARR=GETRESPONSEPLOTLINE()
%   HLINEARR=GETRESPONSEPLOTLINE(NRESP)
%   HLINEARR=GETRESPONSEPLOTLINE(NRESP,HFIG) return the NRESP last line 
%   handles HLINEARR [n_resp n_plot] of a response plot given bei figure
%   handle HFIG. HLINEARR is sorted in the 1st dimension by plot order 
%   (oldest first) and second dimension by the subplot (top left first).
%   By default, NRESP are all responses and HFIG is the current figure
%   handle (GCF).
%
%   Example: hLine_arr=getResponsePlotLine();
%            set(hLine_arr,{'Color'},num2cell(repmat(jet(size(hLine_arr,1)),size(hLine_arr,2),1),2));
%       
%   See also GCF,BODE,SIGMA,NYQUIST,LINE

% REVISIONS:    2016-09-07 first implementation (MP)
% 
% Contact       pusch.research@gmail.com
%
function hLineArr=getResponsePlotLine(nResp,hFig)


if nargin<2 || isempty(hFig)
    hFig=gcf;
end

hLineArr=findobj(hFig,'Type','Line'); % all lines
hLineArr(arrayfun(@(x) isempty(x.XData) | any(isnan(x.XData)),hLineArr))=[];
hAxArr=findobj(hFig,'Type','Axes');
hAxArr(cellfun(@isempty,{hAxArr.Children}))=[];

n_blind=find(strcmp(get(hLineArr,'visible'),'off'),1,'last'); % number of blind/custom plotted lines
if isempty(n_blind)
    n_blind=0;
end
n_plot=numel(hAxArr);
n_sys=(numel(hLineArr)-n_blind)/n_plot;

if nargin<1 || isempty(nResp)
    nResp=n_sys;
elseif nResp>n_sys
    error('n must be <= n_sys');
end

keep_iArr=false(n_sys,n_plot);
keep_iArr(nResp+1:n_sys,:)=true;
keep_iArr=[true(n_blind,1);keep_iArr(:)];

hLineArr=rot90(reshape(hLineArr(~keep_iArr),[],n_plot),2); % lines of 'newest' systems [n n_plot] n_newLine/plot]
