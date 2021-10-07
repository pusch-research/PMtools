 
%% copied and modified from \\rm-samba01\Matlab\Win32\R2015bX64\toolbox\shared\controllib\engine\@DynamicSystem\DynamicSystem.m
function indices = xname2index(sys,indstr,ioflag)
 % Turn references by name into regular subscripts
 %
 %   IND = NAME2INDEX(SYS,STRCELL,IOFLAG) takes a string
 %   vector STRCELL and looks for matching I/O channel or
 %   I/O group names in the system SYS.  The search is
 %   carried out among the outputs if IOFLAG=1, and among
 %   the inputs if IOFLAG=2.
 
 

 if isnumeric(indstr)
     indices=indstr; return
 elseif islogical(indstr)
     indices=find(indstr); return
 elseif isequal(indstr,':')
     indices=1:size(sys,ioflag); return
 elseif isempty(indstr)
     indices=[]; return
 end
%  if isnumeric(indstr) || islogical(indstr) || (ischar(indstr) && strcmp(indstr,':'))
%     indices = indstr;   return
%  end

 % Make sure input is a cell array of strings
 if ischar(indstr)
    indstr = cellstr(indstr);
 elseif ~iscellstr(indstr)
    ctrlMsgUtils.error('Control:ltiobject:subsref1',ioflag)
 end
 if ~isvector(indstr)
    ctrlMsgUtils.error('Control:ltiobject:subsref6')
 end

 % Set name lists for search based on IOFLAG
 if ioflag==1
    ChannelNames = sys.OutputName;
    Groups = sys.OutputGroup;
 else
    ChannelNames = sys.InputName;
    Groups = sys.InputGroup;
 end
 GroupNames = fieldnames(Groups);

 % Perform a string-by-string matching to respect the
 % referencing order
 indices = zeros(1,0);
 nu = length(ChannelNames);
 for ix = 1:length(indstr)
    str = indstr{ix};
    if isempty(str),
       ctrlMsgUtils.error('Control:ltiobject:subsref7',str)
    end
    % Match against channel names and group names
    imatch = localFindMatch(str,[ChannelNames;GroupNames]);
    imatch1 = imatch(imatch<=nu);     % Channel name matches
    imatch2 = imatch(imatch>nu)-nu;   % Group name matches
    nhits1 = numel(imatch1);
    nhits2 = numel(imatch2);
    % Error checks
    if nhits1==0 && nhits2==0,
       ctrlMsgUtils.error('Control:ltiobject:subsref7',str)
    elseif nhits1>0 && nhits2>0
       ctrlMsgUtils.error('Control:ltiobject:subsref8',str)
    elseif nhits2>0
       % Group match
       if nhits2>1,
          ctrlMsgUtils.warning('Control:ltiobject:MultipleGroupMatch',str)
       end
       for ct=1:length(imatch2)
          indices = [indices , Groups.(GroupNames{imatch2(ct)})]; %#ok<AGROW>
       end
    else
       % Channel match
       if nhits1>1,
          % Throw warning unless referring to a vector signal
          SignalNames = regexprep(ChannelNames(imatch),'(\(\d+\))?$','');
          if ~isequal(SignalNames{:})
             ctrlMsgUtils.warning('Control:ltiobject:MultipleChannelMatch',str)
          end
       end
       indices = [indices , imatch1(:)']; %#ok<AGROW>
    end
 end
end
      







function imatch = localFindMatch(str,names)
    % Find all NAMES matching STR using a cascade of matching filters
    nchar = length(str);

    % 1) Start with partial context-insensitive matches
    imatch = find(strncmpi(str,names,nchar));

    % 2) Use case-sensitive partial matching to further narrow hits
    if length(imatch)>1
       icsm = find(strncmp(str,names(imatch),nchar));
       if ~isempty(icsm)
          imatch = imatch(icsm);
       end
    end

    % 3) Look for exact match if there are still multiple hits.
    %    Note that 'y' should be an exact match for 'y' and 'y(*)'
    if length(imatch)>1
       is = regexp(names(imatch),...
          ['^' regexptranslate('escape',str) '(\(\d+\))?$']);
       iexact = find(~cellfun(@isempty,is));
       if ~isempty(iexact)
          imatch = imatch(iexact);
       end
    end
end