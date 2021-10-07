function b=existpath(p)

try
    b=exist(getPath(p),'file');
catch
    b=false; 
end
    