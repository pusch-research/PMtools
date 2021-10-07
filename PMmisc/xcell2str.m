function str=xcell2str(c)

str=cell2str(c);
str(str=='[')=[];
str(str==']')=[];
