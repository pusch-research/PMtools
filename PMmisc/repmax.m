% REPMAX blockwise repeat maximum values
%   
%   B=REPMAX(A,[],dim,dim1sel,..,dimNsel) partiotions the numeric
%   array A in blocks defined by dim1sel,..,dimNsel which are
%   a) vectors of the sizes of the blocks in the respective dimension
%   b) grouping indices
%   c) empty and set to the size of the respective dimension 
%      (no partiotioning in this dimension)
%   Then, the maximum value is determined for each block in dimension DIM 
%   and repeated so the original block size is maintained. If DIM is not 
%   empty, the first nonsingelton dimension is used.
%   The output B has the same size than A.
%
%   Example: A=[1 2;3 4;5 6]; B=repmax(A,1,[1 2])
%            B=
%              1     2
%              5     6
%              5     6
%       
%   See also MAT2CELL, MAX

% REVISIONS:    2015-04-29 first implementation (MP)
% 
% Contact       pusch.research@gmail.com
%
function B=repmax(A,dim,varargin)

% input check
if ~exist('dim','var') || isempty(dim)
   dim = find(size(A)~=1,1);
   if isempty(dim), dim = 1; end 
end
idx_arr=varargin;
if numel(idx_arr)>ndims(A)
    error('wrong number of inputs.')
elseif numel(idx_arr)<ndims(A)
    for i_dim=numel(idx_arr)+1:ndims(A)
       idx_arr{i_dim}=size(A,i_dim); 
    end
end

% convert blk to indices
for i_dim=1:ndims(A)
    if numel(idx_arr{i_dim})~=size(A,i_dim)
       if sum(idx_arr{i_dim})~=size(A,i_dim)
          error(['block sizes in dimension ' num2str(i_dim) ' are invalid.']);
       else
           idx_arr{i_dim}=repval(1:numel(idx_arr{i_dim}),idx_arr{i_dim});
       end
    end
end

% convert inidecs to blk 
blkLength_arr=cell(size(idx_arr));
Ablk=A;
s.type='()';
s.subs=repmat({':'},1,ndims(A));
for i_dim=1:ndims(A)
    n_blk=max(idx_arr{i_dim});
    if n_blk>1
        i_blkStart=1;
        for i_blk=1:n_blk
            % reference struct
            s_ref=s;
            s_ref.subs{i_dim}=find(idx_arr{i_dim}==i_blk);
            % block start/end/length
            blkLength_arr{i_dim}(i_blk)=numel(s_ref.subs{i_dim});
            if i_blk>1, i_blkStart=i_blkStart+blkLength_arr{i_dim}(i_blk-1); end
            i_blkEnd=i_blkStart+blkLength_arr{i_dim}(i_blk)-1;
            % assign struct
            s_asgn=s;
            s_asgn.subs{i_dim}=i_blkStart:i_blkEnd;
            % do permutation
            Ablk=subsasgn(Ablk,s_asgn,subsref(A,s_ref));
        end
    else
        blkLength_arr{i_dim}=numel(idx_arr{i_dim});
    end
end

% convert to cell array of blk
Ablk=mat2cell(Ablk,blkLength_arr{:});

% create max and repeat
for i_blk=1:numel(Ablk)
    sz=ones(1,ndims(Ablk{i_blk})); 
    sz(dim)=size(Ablk{i_blk},dim);
    Ablk{i_blk}=repmat(max(Ablk{i_blk},[],dim),sz);
end

% convert to numeric array & permute back
Ablk=cell2mat(Ablk);
B=Ablk;
for i_dim=1:ndims(A)
    n_blk=max(idx_arr{i_dim});
    if n_blk>1
        i_blkStart=1;
        for i_blk=1:n_blk
            % reference struct
            s_asgn=s;
            s_asgn.subs{i_dim}=find(idx_arr{i_dim}==i_blk);
            % block start/end
            if i_blk>1, i_blkStart=i_blkStart+blkLength_arr{i_dim}(i_blk-1); end
            i_blkEnd=i_blkStart+blkLength_arr{i_dim}(i_blk)-1;
            % assign struct
            s_ref=s;
            s_ref.subs{i_dim}=i_blkStart:i_blkEnd;
            % do permutation
            B=subsasgn(B,s_ref,subsref(Ablk,s_ref));
        end
    end
end







