function s=xgetBlockValue(M,s)

if ischar(s)
    
    % default
    s=getBlockValue(M,s);
    
else
    
    % quick and dirty check if blocks available
    try
        s.Blocks; 
    catch
        % x has no block parameter -> is not tuneable?!
%         warning('no blocks, return input value');
        return
    end
    
    % get values
    blkName_arr=fieldnames(s.Blocks);
    for blkName_act=blkName_arr(:)'
        s.Blocks.(blkName_act{:}).Value=getBlockValue(M,blkName_act{:});
    end
    s=getValue(s);
    
end