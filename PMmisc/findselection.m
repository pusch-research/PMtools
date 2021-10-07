% FINDSELECTION find indices of selected elements
%   
%   IDX=FINDSELECTION(SELECTION,POOL) find indices of selected elements
%   SELECTION in POOL. IDX has the same size as SELECTION and an error
%   is thrown if an element can not be found uniquely.
%       
%   See also STRFIND,STRCMP

% REVISIONS:    2014-09-16 first implementation (MP)
%               2017-05-19 add fieldname (MP)
% 
% Contact       pusch.research@gmail.com
%
function idx=findselection(selection,pool,fieldname)


if nargin>2
    % find selection by field of cell/struct array
    fieldVal_arr=xgetfield(pool,fieldname);
    idx=findselection(selection,fieldVal_arr);
    return;
end

if ischar(selection) && iscellstr(pool)
    selection={selection}; 
end
idx=zeros(size(selection));
n_sel=numel(selection);
if iscellstr(selection) && iscellstr(pool)
    for i_sel=1:n_sel
        i_act=find(strcmp(selection{i_sel},pool));
        if numel(i_act)~=1
           error('findselection:notFound',['element ''' selection{i_sel} ''' not found uniquely.']);
        else
            idx(i_sel)=i_act;
        end
    end
elseif isnumeric(selection) && isnumeric(pool)
    for i_sel=1:n_sel
        i_act=find(selection(i_sel)==pool);
       
        if numel(i_act)~=1
           error('findselection:notFound',['element ''' var2str(selection(i_sel)) ''' not found uniquely.']);
        else
            idx(i_sel)=i_act;
        end
    end
else
    for i_sel=1:n_sel
        i_act=[];

        for i_pool=1:numel(pool)
            if isequal(selection(i_sel),pool(i_pool))
               i_act(end+1)=i_pool; 
            end
        end
        
        if numel(i_act)~=1
           error('findselection:notFound',['element ''' num2str(i_sel) ''' not found uniquely.']);
        else
            idx(i_sel)=i_act;
        end
    end
end