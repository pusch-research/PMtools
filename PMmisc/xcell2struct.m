% XCELL2STRUCT convert cell-array of structures to structure array
%   
%   S=XCELL2STRUCT(C,FIELDNAMES) 

% REVISIONS:    2015-11-19 first implementation (MP)
% 
% Contact       pusch.research@gmail.com
%
function s=xcell2struct(c,fieldNames)


if nargin<2
    for ii=numel(c):-1:1
    	s(ii)=c{ii}; % fieldnames must be equal!
    end
else
    for ii=numel(c):-1:1
        for jj=1:numel(fieldNames)
            s(ii).(fieldNames{jj})=c{ii}.(fieldNames{jj});
        end
    end
end

s=reshape(s,size(c));