function varargout=readPerfSurface(CpCtCqFileName)

% search for row numbers
fid = fopen(CpCtCqFileName);
tline = fgetl(fid);
i_line = 1;
while ischar(tline)
    if length(tline)>5
    switch tline(1:5)
        case '# Pit'
            i_BldPitch=i_line+1;
        case '# TSR'
            i_TSR=i_line+1;
        case '# Win'
            i_WND=i_line+1;
        case '# Pow'
            i_Cp0=i_line+2;
            i_Cp1=i_Cp0-1;
            fgetl(fid); % empty line
            tline = fgetl(fid);
            while ~isempty(tline)
                tline = fgetl(fid);
                i_Cp1=i_Cp1+1;
            end
            i_line=i_Cp1+1;
        case {'#  Th' '# Thr'}
            i_Ct0=i_line+2;
            i_Ct1=i_Ct0-1;
            fgetl(fid); % empty line
            tline = fgetl(fid);
            while ~isempty(tline)
                tline = fgetl(fid);
                i_Ct1=i_Ct1+1;
            end
            i_line=i_Ct1+1;
        case '# Tor'
            i_Cq0=i_line+2;
            i_Cq1=i_Cq0-1;
            fgetl(fid); % empty line
            tline = fgetl(fid);
            while ~isempty(tline)
                tline = fgetl(fid);
                i_Cq1=i_Cq1+1;
            end
            i_line=i_Cq1+1;
    end
    end
    % read next line
    tline = fgetl(fid);
    i_line = i_line + 1;
end
fclose(fid);




%% read surface data

% power coefficient
Cp = readmatrix(CpCtCqFileName, ...
    'FileType', 'text',...
    'Range', [num2str(i_Cp0) ':' num2str(i_Cp1)],...
    'Delimiter', ' ',...
    'ConsecutiveDelimitersRule', 'join',...
    'LeadingDelimitersRule', 'ignore'...
    );
Cp(Cp < 0) = 0; % remove negative entries

% thrust coefficient
Ct = readmatrix(CpCtCqFileName, ...
    'FileType', 'text',...
    'Range', [num2str(i_Ct0) ':' num2str(i_Ct1)],...
    'Delimiter', ' ',...
    'ConsecutiveDelimitersRule', 'join',...
    'LeadingDelimitersRule', 'ignore'...
    );
Ct(Ct < 0) = 0; % remove negative entries

% torque coefficient
Cq = readmatrix(CpCtCqFileName, ...
    'FileType', 'text',...
    'Range', [num2str(i_Cq0) ':' num2str(i_Cq1)],...
    'Delimiter', ' ',...
    'ConsecutiveDelimitersRule', 'join',...
    'LeadingDelimitersRule', 'ignore'...
    );
Cq(Cq < 0) = 0; % remove negative entries

% BldPitch
BldPitch = readmatrix(CpCtCqFileName, ...
    'FileType', 'text',...
    'Range', [num2str(i_BldPitch) ':' num2str(i_BldPitch)],...
    'Delimiter', ' ',...
    'ConsecutiveDelimitersRule', 'join',...
    'LeadingDelimitersRule', 'ignore'...
    );
BldPitch = BldPitch(~isnan(BldPitch)); % remove any NaN's it may have read in

% TSR
TSR = readmatrix(CpCtCqFileName, ...
    'FileType', 'text',...
    'Range', [num2str(i_TSR) ':' num2str(i_TSR)],...
    'Delimiter', ' ',...
    'ConsecutiveDelimitersRule', 'join',...
    'LeadingDelimitersRule', 'ignore'...
    );
TSR = TSR(~isnan(TSR)); % remove any NaN's it may have read in

% Wind
Wind = readmatrix(CpCtCqFileName, ...
    'FileType', 'text',...
    'Range', [num2str(i_WND) ':' num2str(i_WND)],...
    'Delimiter', ' ',...
    'ConsecutiveDelimitersRule', 'join',...
    'LeadingDelimitersRule', 'ignore'...
    );
Wind = Wind(~isnan(Wind)); % remove any NaN's it may have read in

%% read TSR data
if nargout==1

   data.TSR=TSR;
   data.BldPitch=BldPitch;
   data.Wind=Wind;
   data.Cp=Cp;
   data.Ct=Ct;
   data.Cq=Cq;

   varargout={data};
else
    varargout={Cp,Ct,Cq,BldPitch,TSR,Wind};
end


