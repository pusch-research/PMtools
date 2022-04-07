function [sys,d,V,Tinv,bKeep,cKeep,blksize]=xcanon(sys,method,varargin)
% create diagonal system (with sorted complex entries)
% last poles are the poles which are not associated to the inputs/output defined in uKeep/yKeep 
% note: the size/order of sys is not changed


%% handle inputs


% user defined parameters
uKeep_iArr=[]; % keep inputs and eliminate non-required states using sminreal {':'/idx: keep selected inputs and carry out sminreal,[]: keep all inputs without carrying out sminreal}
yKeep_iArr=[]; % keep outputs and eliminate non-required states using sminreal {':'/idx: keep selected outputs and carry out sminreal,[]: keep all outputs without carrying out sminreal}
xKeep_iArr=[]; % keep states {':'/idx: keep selected states} 
xKeepEnforced=true; % enforce to (at least) keep states xKeep_iArr

% overwrite userdefined parameters (varargin) and delete them from varargin to pass on varargin 
ii=1;
while ii<numel(varargin)
    if ischar(varargin{ii}) && exist(varargin{ii},'var')
        eval([varargin{ii} '=varargin{ii+1};']);
        varargin(ii:ii+1)=[];
    else
        ii=ii+1;
    end
end

% throw warning if descriptor system
if ~isempty(sys.e)
    warning('descriptor system (E~=0)!');
end
% extract data
[a,b,c,~]=ssdata(sys);
% get sizes
n_x=order(sys);
[n_y,n_u]=size(sys);


%% set defaults

% default method
if nargin<=1
    method='diagonal';
end


% xKeep_iArr
if isempty(xKeep_iArr) || isequal(xKeep_iArr,':')
    xKeep_iArr=true(n_x,1); % default: keep all states
end
if isnumeric(xKeep_iArr)
    xKeep_iArr=ismembc(1:n_x,xKeep_iArr)'; % make logical
end
xKeep_iArr=xKeep_iArr(:); % ensure column vector

% uKeep_iArr
if isequal(uKeep_iArr,':')
    uKeep_iArr=true(n_u,1); % default: keep all inputs
end
if ~isempty(uKeep_iArr) && isnumeric(uKeep_iArr)
    uKeep_iArr=ismembc(1:n_u,uKeep_iArr)'; % make logical
end

% yKeep_iArr
if isequal(yKeep_iArr,':')
    yKeep_iArr=true(n_y,1); % default: keep all outputs
end
if ~isempty(yKeep_iArr) && isnumeric(yKeep_iArr)
    yKeep_iArr=ismembc(1:n_y,yKeep_iArr)'; % make logical
end


%% initialization

% eliminate all states which are not required for IO behaviour
if isempty(uKeep_iArr) && isempty(yKeep_iArr) 
    xuyKeep_iArr=xKeep_iArr; % set to xKeep_iArr and don't carry out sminreal
else
    [~,xuyKeep_iArr]=sminreal(sys(yKeep_iArr,uKeep_iArr)); % if yKeep or uKeep is set, sminreal is carried out!
end


% checks
if ~all(xuyKeep_iArr(xKeep_iArr)) % xKeep is NOT a subset of xuyKeep -> adapt one of them 
    if xKeepEnforced
        %warning('input/output selection eliminates states which are enforced to be kept. xuyKeep_iArr is adapted.');
        xuyKeep_iArr=xKeep_iArr | xuyKeep_iArr; % also keep states defined in xKeep_iArr
    else
        %warning('input/output selection eliminates states which are meant to be kept. xKeep_iArr is adapted.');
        xKeep_iArr(xKeep_iArr)=xuyKeep_iArr(xKeep_iArr); % do not keep states which are not kept by xuyKeep_iArr
    end
end
if any(any(a(~xuyKeep_iArr,xuyKeep_iArr))) && any(any(a(xuyKeep_iArr,~xuyKeep_iArr)))
    figure;
    spy(a); 
    mm=minmax([find(xuyKeep_iArr,1,'first') find(xuyKeep_iArr,1,'last')]); %! TODO: make better
    rectangle('Position',[mm(1)-0.5 mm(1)-0.5 diff(mm)+1 diff(mm)+1],'EdgeColor','r') %! TODO: draw rectangles over rows/cols (epsecially when xIgnore_iArr is not continuous)
    error('partial diagonalization not possible if coupling terms are not zero.');
end

% reduce system matrix
a_red=a(xuyKeep_iArr,xuyKeep_iArr);
b_red=b(xuyKeep_iArr,:);
c_red=c(:,xuyKeep_iArr);
n_xRed=length(a_red);




%% carry out canon

if strcmpi(method(1:4),'diag') % fully diagonalize (complex ss)
    
    % eigenvalue decomposition (incl. sorting)
    [V,d,W]=xeig(a_red,varargin{:}); 
    W=W/(V'*W);

    % find poles with eigenvectors containing entries of xuyKeep_iArr but not xKeep_iArr 
    tmp=double(xuyKeep_iArr); % convert to double
    tmp(xuyKeep_iArr)=1:n_xRed; % replace all true with ascending index
    tmp=tmp(xor(xuyKeep_iArr,xKeep_iArr)); % select indices associated to elements of xuyKeep_iArr which are not in xKeep_iArr
    poleKeep_iArr=~any(V(tmp,:),1); 
    
    % permute states so that poles with eigenvectors associated to xKeep are queued first
    permOrder=1:n_xRed;
    permOrder=[permOrder(poleKeep_iArr) permOrder(~poleKeep_iArr)];
    d=d(permOrder);
    W=W(:,permOrder);
    V=V(:,permOrder);
    
    % make transformation matrix
    T=eye(n_x);
    T(xuyKeep_iArr,xuyKeep_iArr)=V;
    Tinv=eye(n_x);
    Tinv(xuyKeep_iArr,xuyKeep_iArr)=W'; % alternative: inv(V)

    % system matrices
    if ~all(xuyKeep_iArr)
        a=Tinv*a*T; % =W'*a*V = V\a*V;
    else
        a=diag(d); % numerically better?!
    end
    b=Tinv*b;
    c=c*T;


elseif strcmpi(method,'jordan')

    %% real modal canon trafo (using local copy of canon.m)   
      
    
    if isdiag(a_red) % given in diagonal form
        blksize=[];
        ii=1;
        while ii<=length(a_red)
            a_=a_red(ii,ii);
            b_=b_red(ii,:);
            c_=c_red(:,ii);
            if imag(a_)~=0 % conjugate complex pole
                if abs(conj(a_)-a_red(ii+1,ii+1))>sqrt(eps)
                   error('no conjugate complex pole. please check/sort.'); 
                end
                if abs(conj(b_)-b_red(ii+1,:))>sqrt(eps)
                   error('no conjugate complex input matrix. please check/sort.'); 
                end
                if abs(conj(c_)-c_red(:,ii+1))>sqrt(eps)
                   error('no conjugate complex output matrix. please check/sort.'); 
                end
                % trafo matrix T=[1 1;-i +i]/sqrt(2) and Tinv=[1 i;1 -i]/sqrt(2); see also ss2ss(sys,T);
                a_red(ii+[0 1],ii+[0 1])=[real(a_) imag(a_); -imag(a_) real(a_)];
                b_red(ii+[0 1],:)=sqrt(2)*[real(b_);-imag(b_)];
                c_red(:,ii+[0 1])=sqrt(2)*[real(c_) imag(c_)];
                blksize(end+1)=2;
                ii=ii+2;
            else % real pole
                blksize(end+1)=1;
                ii=ii+1;
            end
        end
        sys.a(xuyKeep_iArr,xuyKeep_iArr)=a_red;
        sys.b(xuyKeep_iArr,:)=b_red;
        sys.c(:,xuyKeep_iArr)=c_red;
        d=diag(a_red);
        V=eye(length(d));
        bKeep=b(xuyKeep_iArr,uKeep_iArr);
        cKeep=c(yKeep_iArr,xuyKeep_iArr);
        Tinv=eye(length(a));
       
        return;
    end
    
    if ~all(xuyKeep_iArr)
        error('not tested!');
    end
    
    % userdefined parameters
    cond_max=[];
    n_digits=[];   % default: use number accuracy of sqrt(eps)
    
    % overwrite userdefined parameters
    for ii=1:2:numel(varargin) 
        if ~exist(varargin{ii},'var')
            warning(['optional input parameter ''' varargin{ii} ''' is not declared.']);
        end
        eval([varargin{ii} '=varargin{ii+1};']);
    end
    if isempty(n_digits)
        n_digits=round(abs(log10(sqrt(eps))));
    end
    
    % compute real modal canon form
    [a_red,V,blksize]=canon_LOCAL(a_red,cond_max); % where a_sub=V\a_sub*V with max. blockSize of 2 (no repeated poles)
    n_blk=numel(blksize);
    
    if any(blksize>2)
        warning('xcanon:blkSize','blksize>2 not tested.');
    end
    
    % get eigenvalues 
    d=zeros(length(a_red),1);
    ii=1;
    for i_blk=1:n_blk
        if blksize(i_blk)==1 % real pole
            d(ii)=a_red(ii,ii);
        elseif blksize(i_blk)==2 && abs(a_red(ii,ii+1)+a_red(ii+1,ii))<sqrt(eps) % conjugate complex pole
            d(ii)=a_red(ii,ii)+1j*a_red(ii,ii+1);
            d(ii+1)=a_red(ii+1,ii+1)+1j*a_red(ii+1,ii);
        else % multiple poles (blksize>2 or one of the non-diagonal elements is zero)
            d_act=eig(a_red(ii+(0:blksize(i_blk)-1),ii+(0:blksize(i_blk)-1)));
            d_act=sort(round(d_act,n_digits,'significant')); % sort directly to leave (n>2)block untouched
            d(ii+(0:blksize(i_blk)-1))=d_act;
        end
        ii=ii+blksize(i_blk);
    end
    
    % sort    
    d=round(d,n_digits,'significant'); % eliminate numerical errors
    % sort blocks
    [~,sortBlk_iArr]=sort(d(cumsum(blksize))); % select first eigenvalue of each block 
    % sort poles
    sort_iArr=zeros(size(d));
    ii=1; % index of first block entry (sorted)
    for i_blk=1:n_blk % loop sorted blocks
        blksize_act=blksize(sortBlk_iArr(i_blk));
        jj=sum(blksize(1:sortBlk_iArr(i_blk)-1))+1; % index of first block entry (unsorted)
        sort_iArr(ii-1+(1:blksize_act))=jj-1+(1:blksize_act); % copy full blok
        if blksize_act==2 && imag(d(jj))>0
            sort_iArr([ii ii+1])=sort_iArr([ii+1 ii]); % switch pos/neg imag part
        end
        ii=ii+blksize_act;
    end
    d=d(sort_iArr);
    
    
    %[d,sort_iArr]=sort(d); % sort eigenvalues by magnitude (=frequency) and phase (for equal magnitudes, pole with NEGATIVE imaginary part comes first as it has a smaller phase angle)
    %sort_iArr=1:numel(d);
    
    % make transformation matrix
    T=eye(n_x);
    T(xuyKeep_iArr,xuyKeep_iArr)=V(:,sort_iArr);
    
    % system matrices
    if ~all(xuyKeep_iArr)
        a=T\a*T;
    else
        a=a_red(sort_iArr,sort_iArr); % numerically better?!
    end
    b=T\b;
    c=c*T;
    
    Tinv=inv(T);
    
    blksize=blksize(sortBlk_iArr);

    
    
elseif strcmp(method,'control')
    
    %% controlable canonical form
    
    % check
    if nargout>1
        error('not implemented');
    elseif ~all(xuyKeep_iArr)
        error('not implemented');
    end
     
    % userdefined parameters
    cond_max=[];
    n_digits=[];
    blksize=[];
    i_refInput=1;% choose first control input as a reference input (default)

    % overwrite userdefined parameters
    for ii=1:2:numel(varargin) 
        if ~exist(varargin{ii},'var')
            warning(['optional input parameter ''' varargin{ii} ''' is not declared.']);
        end
        eval([varargin{ii} '=varargin{ii+1};']);
    end
    
    % to jordan normal form first
    if isempty(blksize)
        [sys,~,~,~,~,~,blksize]=xcanon(sys,'jordan','cond_max',cond_max,'n_digits',n_digits);
    end
    blksize=blksize(:);

    % to controlable normal form
    [a,b,c,~]=ssdata(sys);
    blkIdx_arr=cumsum([1;blksize(1:end-1)]); % index of first block entrys
    for ii=1:numel(blksize)
        
        blkSize_act=blksize(ii);
        blkIdx=blkIdx_arr(ii):blkIdx_arr(ii)+blkSize_act-1; % all indices of block
        
        if blkSize_act==1
            
            c(:,blkIdx)=c(:,blkIdx)*b(blkIdx,1);
            b(blkIdx,:)=b(blkIdx,:)/b(blkIdx,1); 
            
        elseif blkSize_act==2
            
            a_act=a(blkIdx,blkIdx);
            b_act=b(blkIdx,:);
            c_act=c(:,blkIdx);

            % check
            if norm(a_act(1,:)-[0 1])<sqrt(eps) && norm(b_act(:,i_refInput)-[0;1])<sqrt(eps)
                continue; % already in controllable normal form
            elseif abs(a_act(1,1)-a_act(2,2))>sqrt(eps) ||...
                   abs(a_act(1,2)+a_act(2,1))>sqrt(eps)
                error('not in jordan normal form.');
            end

            % build trafo matrix
            b_ref=b_act(:,i_refInput); 
            if norm(b_ref)==0
                error('mode is not controllable from reference input.');
            end
            T=[-a_act'*b_ref b_ref];

            % trafo of block
            a_act=T\a_act*T;
            a_act(1,:)=[0 1]; % overwrite for better numerical accuracy
            b_act=T\b_act;
            c_act=c_act*T;

            % save
            a(blkIdx,blkIdx)=a_act;
            b(blkIdx,:)=b_act;
            c(:,blkIdx)=c_act;

        else

           error('not implemented.'); 

        end

    end
   
elseif strcmp(method,'observe')
    
    %% observable canonical form
    
    % check
    if nargout>1
        error('not implemented');
    elseif ~all(xuyKeep_iArr)
        error('not implemented');
    end
     
    % userdefined parameters
    cond_max=[];
    n_digits=[];
    blksize=[];
    i_refOutput=1;% choose first control input as a reference input (default)

    % overwrite userdefined parameters
    for ii=1:2:numel(varargin) 
        if ~exist(varargin{ii},'var')
            warning(['optional input parameter ''' varargin{ii} ''' is not declared.']);
        end
        eval([varargin{ii} '=varargin{ii+1};']);
    end
    
    % to jordan normal form first
    if isempty(blksize)
        [sys,~,~,~,~,~,blksize]=xcanon(sys,'jordan','cond_max',cond_max,'n_digits',n_digits);
    end
    blksize=blksize(:);

    % to observable normal form
    [a,b,c,~]=ssdata(sys);
    blkIdx_arr=cumsum([1;blksize(1:end-1)]); % index of first block entrys
    for ii=1:numel(blksize)
        
        blkSize_act=blksize(ii);
        blkIdx=blkIdx_arr(ii):blkIdx_arr(ii)+blkSize_act-1; % all indices of block
        
        if blkSize_act==1
            
            c(:,blkIdx)=c(:,blkIdx)*b(blkIdx,1);
            b(blkIdx,:)=b(blkIdx,:)/b(blkIdx,1); 
            
        elseif blkSize_act==2
            
            a_act=a(blkIdx,blkIdx);
            b_act=b(blkIdx,:);
            c_act=c(:,blkIdx);

            % check
            if norm(a_act(1,:)-[0 1])<sqrt(eps) && norm(c_act(i_refOutput,:)-[0 1])<sqrt(eps)
                continue; % already in observable normal form
            elseif abs(a_act(1,1)-a_act(2,2))>sqrt(eps) ||...
                   abs(a_act(1,2)+a_act(2,1))>sqrt(eps)
                error('not in jordan normal form.');
            end

            % build trafo matrix
            c_ref=c_act(i_refOutput,[2 1]); 
            c_ref(2)=-c_ref(2);
            if norm(c_ref)==0
                error('mode is not observable from reference output.');
            end
            T=[-a_act'*c_ref' c_ref']/norm(c_act(i_refOutput,:)*a_act'*c_ref');

            % trafo of block
            a_act=T\a_act*T;
            a_act(1,:)=[0 1]; % overwrite for better numerical accuracy
            b_act=T\b_act;
            c_act=c_act*T;

            % save
            a(blkIdx,blkIdx)=a_act;
            b(blkIdx,:)=b_act;
            c(:,blkIdx)=c_act;

        else

           error('not implemented.'); 

        end

    end
    
    
elseif strcmp(method,'physical')

    %% physical modal system (as in structural modeling)
    
    % userdefined parameters
    cond_max=[];

    % overwrite userdefined parameters
    for ii=1:2:numel(varargin) 
        if ~exist(varargin{ii},'var')
            warning(['optional input parameter ''' varargin{ii} ''' is not declared.']);
        end
        eval([varargin{ii} '=varargin{ii+1};']);
    end
    
    % make real Jordan form
    if any(imag(a_red(:))~=0)
        [a_red,b_red,c_red]=ssdata(xcanon(ss(a_red,b_red,c_red,0),'jordan'));
        ii=length(a_red);
        blksize=ones(ii,1);
        while ii>0
            blksize_act=sum(a_red(ii,:)~=0);
            ii=ii-blksize_act+1;
            blksize(ii)=blksize_act;
            blksize(ii+1:ii+blksize_act-1)=[];
            ii=ii-1;
        end
    else
        [a_red,Tm,blksize]=canon_LOCAL(a_red,cond_max); % where Am=Tm\A*Tm with max. blockSize of 2 (no repeated poles required)
        b_red=Tm\b_red;
        c_red=c_red*Tm;
    end
    
    
    % loop blocks
    Tae=eye(size(a_red));
    ii=0;
    for i_blk=1:numel(blksize)
        
        % transform 2x2 blocks 
        if blksize(i_blk)==2
            
            ii=ii+1:ii+blksize(i_blk);

            Tae(ii,ii)=getTae_LOCAL(a_red(ii,ii),b_red(ii,1));
            a_red(ii,ii)=Tae(ii,ii)\a_red(ii,ii)*Tae(ii,ii);
            b_red(ii,:)=Tae(ii,ii)\b_red(ii,:);
            c_red(:,ii)=c_red(:,ii)*Tae(ii,ii);
            
            ii=ii(end);
            
        else
            
           ii=ii+blksize(i_blk); 
           
        end
        
    end
    
    % make transformation matrix
    T=eye(n_x);
    T(xuyKeep_iArr,xuyKeep_iArr)=Tae;
    
    % system matrices
    if ~all(xuyKeep_iArr)
        a=T\a*T;
        b=T\b;
        c=c*T;
    else
        a=a_red; % numerically better?!
        b=b_red;
        c=c_red;
    end

    
    
else

    error('not implemented.');

end
        

   

  
%% overwrite system matrices    
sys.a=a;
sys.b=b;
sys.c=c;
sys.StateName={}; 
%sys=ssbal(sys); % for better conditioning -> not for controllable canonical form!!

bKeep=b(xuyKeep_iArr,uKeep_iArr);
cKeep=c(yKeep_iArr,xuyKeep_iArr);







%% check
% D1=D; D1(D==0)=1;
% if any(any(abs((a-D)./D1)>sqrt(eps)))
%     warning('not equal.');
% end






























%%
function [Tae]=getTae_LOCAL(Am,bm)
% input:  Am=diagonalized matrix block [-w0*zeta wd;-wd -w0*zeta]
%         bm=input (scaling) vector [2 x 1]
%         with (Am,bm) must be controllable
% output: Tae=transformation matrix so that Tae\Am*Tae=[0 1;-w0^2 -2*w0*zeta]
%             and bae=Tae\bm=[0;1]

%% symbolic solution (pasted below)
% clear all
% syms a11 a12 real
% syms b1 b2 real
% 
% b=[b1;b2];
% Am=[a11 a12;-a12 a11];
% Tae=inv([b Am*b]);
% Tae=Tae(2,:)';
% Tae=inv([Tae Am'*Tae]'); % = [-Am'*b b]


%% compute Tae
a11=Am(1,1);a12=Am(1,2); a21=Am(2,1);a22=Am(2,2);
b1=bm(1);
b2=bm(2);

if abs(a11-a22)>sqrt(eps) || abs(a21+a12)>sqrt(eps)
    error('wrong input.');
end
    
% Tae=[                                                                b2/(a12*b2^2 - a21*b1^2 + a11*b1*b2 - a22*b1*b2),                                                               -b1/(a12*b2^2 - a21*b1^2 + a11*b1*b2 - a22*b1*b2) ;...
%        (a11*b2)/(a12*b2^2 - a21*b1^2 + a11*b1*b2 - a22*b1*b2) - (a21*b1)/(a12*b2^2 - a21*b1^2 + a11*b1*b2 - a22*b1*b2), (a12*b2)/(a12*b2^2 - a21*b1^2 + a11*b1*b2 - a22*b1*b2) - (a22*b1)/(a12*b2^2 - a21*b1^2 + a11*b1*b2 - a22*b1*b2)];
Tae =[ -a11*b1+a12*b2 , b1 ;...
       -a12*b1-a11*b2 , b2];

   
%%
function [Am,Tm,blkSize] = canon_LOCAL(A,condmax)
% Copy from C:\Program Files\Matlab\R2014bX64\toolbox\shared\controllib\engine\+ltipack\@ssdata\canon.m
% Modal Canonical realization of state-space model (without input/output matrix)

if nargin<2 || isempty(condmax)
   condmax=1e8; % see C:\Program Files\Matlab\R2014bX64\toolbox\shared\controllib\engine\@DynamicSystem\canon.m 
end
na = size(A,1);
if na<=1
    Tm=eye(na);
    return
end

% scale for numerical reasons
% [A,~,~,~,s,p] = xscale(A,zeros(na,0),zeros(0,na),[],[],0); % matlab 2019 or lower
[A,~,~,~,s] = xscale(A,zeros(na,0),zeros(0,na),[],[],0); % matlab 2021b


% Modal form
if isreal(A)
    [Tm,A,blkSize] = bdschur(A,condmax);
    
    if any(blkSize>2)
        warning('bdschur:blkSize','blkSize>2, increase condmax?'); % DO NOT CONTINUE FROM HERE AS SCALING BELOW FAILS!!!
    end

    % Rescale 2x2 blocks in Schur form to look like [s w;-w s]
    % (s and w then give the real and imaginary parts of the
    % complex poles)
    idxBlks = find(diag(A,-1));
    for ct = 1:length(idxBlks)
       n = idxBlks(ct);
       % Scale 2x2 block
       %    a(n:n+1,n:n+1) = [ s  q ] to  [  s  w ]
       %                     [ r  s ]     [ -w  s ]
       %    w = sqrt(abs(q*r))
       % Scaling factor = sign(q) * sqrt(q/r)
       sfactor = sign(A(n,n+1)) * sqrt(abs(A(n+1,n)/A(n,n+1)));
       % Set off-diagonal terms to w and -w by applying scaling
       A(:,n+1) = A(:,n+1)*sfactor;
       A(n+1,:) = A(n+1,:)/sfactor;
       % Augment T with scaling factor
       Tm(:,n+1) = Tm(:,n+1)*sfactor;
    end
else
    error('not implemented.')
    % REVISIT: need complex version of BDSCHUR
    % [T,a] = eig(a);
end

% backscale/output
% Tm = diag(s) * Tm(p,:); % matlab 2019 or lower
Tm = diag(s)*Tm; %inv(Tm) ./ s';  % matlab 2021b
Am = A;
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
