function s=parval2struct(p,v)

s=struct();

for ii=1:numel(p)
    fieldName_arr=strsplit(p{ii},'.');
    s.(fieldName_arr{:})=v{ii};
end
