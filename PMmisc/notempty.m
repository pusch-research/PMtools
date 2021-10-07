function b=notempty(s,fieldname)

% check if struct field exists and is not empty
b=isfield(s,fieldname) && ~isempty(s.(fieldname));


% % array of fieldnames:
% b=isfield(s,n);
% if iscll(n)
%     b(b)=arrayfun(@(x) ~isempty(s.(n{x})),find(b));
% elseif b
%     b=~isempty(s.(n));
% end
% b=~b;