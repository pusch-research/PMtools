function mem=mb(varargin)
%
%Issuing the command MB returns the number of megabytes of used memory
%as tracked by WHOS().
%
%MB X Y will display the memory in MB consumed (according to whos) by variables X %and Y

if nargin==0

  cmdstr=['whos;'];
  s=evalin('caller', cmdstr) ;

else
    in=['''' varargin{1} ''''];

    numargs=length(varargin);

    if numargs>1
    for ii=2:numargs
        in= [in ',' '''' varargin{ii} ''''];
    end
    end

    cmdstr=['whos(' in ');'];

    s=evalin('caller', cmdstr) ;
    
end

if length(s)<1, mem=0; return; end

c=cell(1,length(s));
[c{:}]=deal(s.bytes);
c=vertcat(c{:});
mem=sum(c)/2^20; 