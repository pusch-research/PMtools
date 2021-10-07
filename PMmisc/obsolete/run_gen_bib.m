
% conference or journal part of DOI
doi_base = '10.2514/'; % AIAA Scitech 2016

% get directory listing
filelist = dir;

% look for PDF files and interpret the filename as the paper part DOI (common for AIAA papers)
i_doi = 1;
clear('doi_string');
for i_file = 1:length(filelist)
    
    [pathstr, name, ext] = fileparts(filelist(i_file).name);
    if strcmpi(ext, '.pdf')
        fileName_arr{i_doi}=filelist(i_file).name;
        i_doi = i_doi+1;
    end
    
end
n_doi = length(fileName_arr);


% retrieve individual bibtex entries
bib_string_file = [];
for i_doi = 1:n_doi;
    
    [pathstr, name, ext] = fileparts(fileName_arr{i_doi});
    
    % get doi
    i0=strfind(name,'@');
    if isempty(i0)
        i0=0;
    end
    doi_paper = name(i0+1:end);
    
    
    % query of bibtex entry from DOI
    bib_string = xurlread(['http://dx.doi.org/' doi_base doi_paper], 'get', {}, {'accept', 'application/x-bibtex'});

    % find retruns in string
    idx_return = find(bib_string == 10);
    

    
    
    % extract data for file rename
    year=bib_string(idx_return(3)+9:idx_return(4)-2);
    authors=strsplit(bib_string(idx_return(6)+12:idx_return(7)-3),' and ');
    authors=cellfun(@(x) strsplit(x,' '),authors,'un',false);
    authors=strjoin(cellfun(@(x) x{end},authors,'un',false),', ');
    title=bib_string(idx_return(7)+11:idx_return(8)-3);
    title(title=='/' | title==':')=','; % replace not allowed (common) signs
    title(title=='{' | title=='}')=''; % delete {}
    newFileName=[year ' ' authors ' - ' title ext];
    
    % rename file
    movefile(fileName_arr{i_doi},fullfile(pathstr,newFileName));
    
    % assemble bibtex file (including file link to pdf)
    bib_string_file = [ bib_string_file ...
        bib_string(1:idx_return(1)) ...
        '    file = {' newFileName '.pdf:' newFileName '.pdf:PDF},' char(10) ...
        bib_string(idx_return(1)+1:end) char(10) char(10)];
    
    
end

% % write bibtex file
% if ~exist('SciTech2016_papers.bib', 'file')
%     fid = fopen('SciTech2016_papers.bib', 'w');
%     fwrite(fid, bib_string_file);
%     fclose(fid);
% end

% you may need to remove double entries

