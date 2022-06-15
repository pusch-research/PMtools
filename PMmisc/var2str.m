function str = var2str(v)
% VAR2STR Convert variable to string
%
%   STR = VAR2STR(V) converts the variable V into a string
%   representation STR, which is executable to produce the original
%   variable.
%
%   See also: EVAL, MAT2STR, CELL2STR, STRUCT2STR

switch class(v)
    case  'char'
        str = ['[''' regexprep(v, {''''   , '\n'            }, ...
                                  {'''''' , ''' char(10) '''}) ''']']; 
    case  'double'
        str = mat2str(v);
    case {'int8' 'int16' 'int32'}
        str = [class(v) '(' mat2str(v) ')'];
    case {'cell' 'struct' 'logical'}
        fun = str2func([class(v) '2str']);
        str = fun(v);
    case 'function_handle'
        str = func2str(v);
    otherwise
        error('DLR:var2str:BadClass', 'This variable cannot be converted into at string yet! Please extend the function var2str!')
end

