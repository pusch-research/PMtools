function cstruct = combine_struct(struct1,struct2) % struct2 overwrites struct1

cstruct = struct1;

names = fieldnames(struct2);

for i_name = 1:length(names)
   if isfield(cstruct,names{i_name})
      %warning(['Field ' names{i_name} ' exist in both structures. Using first structure.']); % 14-11-28 most annoying warning ever! manuel.pusch@dlr.de
   else
       cstruct.(names{i_name}) = struct2.(names{i_name});
   end
end

