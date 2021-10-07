function xmf_export(filename, varargin)
%XMF_EXPORT Extends the possibilities of matlabfrag for creating LaTeX figures
%
% XMF_EXPORT runs matlabfrag and/or (pdf)latex to create a LaTeX figure from a
% matlab figure. Depending on the options, an eps and a tex (which can be used with
% LaTeX) and/or a pdf file (for pdfLaTex) is created). In addition, it is possible to
% create Preview of the final output
%
% Function call:	XMF_EXPORT(FILENAME)
%                   XMF_EXPORT(FILENAME, OPTIONS)
% Input variables:  FILENAME   is the name of the created eps/tex/pdf
%                   OPTIONS    additional options are added in 'key'
%                              and 'value' pairs:
%                       KEYS:
%                         - source (gcf, figure handle, filename)
%                             Is a figure handle, which is to be converted.
%                             For creating a pdf or a preview of an existing
%                             eps/tex file pair the filename (with out extension)
%                             can be used, too.
%                                 NOTE: In this case and if source equals filename
%                                       it is possible, that original files are
%                                       modified or deleted!!!
%                         - handle
%                             Same as source.
%                         - output (eps_tex, pdf, both)
%                             Defines whether a eps/tex file pair, a pdf or both shall
%                             be created. The two latter are only possible if compiler
%                             is pdfLaTeX.
%                         - compiler (latex, pdflatex)
%                             Defines if latex or pdflatex is used.
%                         - header   ([], user specific LaTeX header file)
%                             Specifies a tex file, where the latex preamble
%                             is defined. Own LaTeX commands may be defined
%                             there. Note, the header must inclued the latex
%                             pstool package with following options
%                                   \usepackage[process=all, cleanup={}]{pstool}
%                             If no header is specified, a default one is used
%                         - fixline (false, true)
%                             If true, fixPSlinestyle is executed to fix the linesytiles
%                             with in the eps file.
%                         - preview (none, pdf, ps, dvi)
%                             Define if preview shall be created. For pdflatex the preview
%                             format must be pdf, for latex pdf, ps or dvi is possible.
%                         - del_files
%                             By default, all temporary files are deleted. This
%                             can be avoided by using the key value pair
%                             ... 'del_files', false ...
%                         - all other keys are delivered to matlabfrag
%
% Default values can be modfied using xmf_init.
%
% Note:     The correct execution of XMF_EXPORT requires that latex
%           is installed and in the OS search path.
%
% See also: MATLABFRAG XMF_INIT XMF_PREPARE XMF_FIGURE XMF_SUBPLOT FIXPSLINESTYLE


% SET OPTIONS ACCORDING TO [pathstr,namestr] = fileparts(FileName)


%% Input check
% Filename
if nargin == 0
    error('Xmatlabfrag requires at least one input')
end
if isempty(filename)
    error('Xmatlabfrag requires a valid filename')
end

% get default values
settings = xmf_init();
settings = settings.xmf_export;

% Source or handle
ii_opt = find(ismember(varargin(1:2:end), {'source' 'handle'}));
if isempty(ii_opt)
    source = settings.source();
else
    source = varargin{2*ii_opt};
    varargin(2*ii_opt-[1 0]) = [];
end

% output
ii_opt = find(ismember(varargin(1:2:end), {'output'}));
if isempty(ii_opt)
    output = settings.output;
else
    output = varargin{2*ii_opt};
    varargin(2*ii_opt-[1 0]) = [];
end

% compiler
ii_opt = find(ismember(varargin(1:2:end), {'compiler'}));
if isempty(ii_opt)
    compiler = settings.compiler;
else
    compiler = varargin{2*ii_opt};
    varargin(2*ii_opt-[1 0]) = [];
end

% header
ii_opt = find(ismember(varargin(1:2:end), {'header'}));
if isempty(ii_opt)
    if isempty(settings.header)
        latex_header = mfilename('fullpath');
        latex_header = latex_header(1:find(latex_header=='\', 1, 'last'));
        latex_header(latex_header=='\') = '/';
        latex_header = [latex_header 'xmf_header.tex'];
    else
        latex_header = settings.header;
    end
else
    latex_header = varargin{2*ii_opt};
    varargin(2*ii_opt-[1 0]) = [];
end


% fixline
ii_opt = find(ismember(varargin(1:2:end), {'fixline'}));
if isempty(ii_opt)
    fixline = settings.fixline;
else
    fixline = varargin{2*ii_opt};
    varargin(2*ii_opt-[1 0]) = [];
end

% preview
ii_opt = find(ismember(varargin(1:2:end), {'preview'}));
if isempty(ii_opt)
    preview = settings.preview;
else
    preview = varargin{2*ii_opt};
    varargin(2*ii_opt-[1 0]) = [];
end


% del files
ii_opt = find(ismember(varargin(1:2:end), {'del_files'}));
if isempty(ii_opt)
    del_files = settings.del_files;
else
    del_files = varargin{2*ii_opt};
    varargin(2*ii_opt-[1 0]) = [];
end


%% Define filename
cur_dir    = pwd;
[fp fn]    = fileparts(filename);
latex_file = ['XMF_tmp_doc_' fn '_' datestr(now,'yyyymmdd-HHMMSS')];
fig_file   = fn;
PV_file    = [fn '_XMF_PV'];



if ~isempty(fp)
    if ~exist(fp, 'dir')
        mkdir(fp)
    end
    cd(fp);
end

try    
    %% Run Matlabfrag if necessary
    if ishandle(source)
        matlabfrag(fig_file, 'handle', source, varargin{:});
        source = fig_file;
    else
        try
            copyfile([source '.eps'], [fig_file '.eps'], 'f')
            copyfile([source '.tex'], [fig_file '.tex'], 'f')
        catch e
            if ~isequal(e.identifier, 'MATLAB:COPYFILE:SourceAndDestinationSame')
                rethrow(e)
            elseif isequal(output, 'pdf')
                output = 'both';
                warning('xmf_export:SourceEqualsOutput', 'Source Equals Output! Original eps file can be changed! Option output changed to both!')
            else
                warning('xmf_export:SourceEqualsOutput', 'Source Equals Output! Original eps file can be changed!')
            end
        end
    end
    
    %% Run fixlines if required
    if fixline
        fixPSlinestyle([source '.eps'], [fig_file '.eps'])
    end
    
    %% PDFLatex
    if ismember(compiler, {'pdflatex', 'PDFlatex', 'PDFLATEX'})
        %% Make Input check
        if ~ismember(output, {'eps_tex', 'pdf', 'both'})
            error('In pdfLaTeX mode output must be one ''eps_tex'', ''pdf'' or ''both''')
        end
        
        if ~ismember(preview, {'none' 'pdf'})
            error('In pdfLaTeXLaTeX mode only ''none'' and ''pdf'' are support as preview')
        end
        
        %% If pdf or preview requested
        if ismember(output, {'pdf', 'both'}) || ismember(preview, {'pdf'})
            %% Create Latex File
            % Open files
            fid_lf = fopen([latex_file '.tex'], 'w+');
            fid_hf = fopen(latex_header, 'r');
            if fid_hf==-1
                error('Error opening figure header.')
            end
            
            % Print some comment
            fprintf(fid_lf, '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
            fprintf(fid_lf, '%%  LaTeX File to create matlabfrag preview               %%\n');
            fprintf(fid_lf, '%%  Created by xmf_export at %s             %%\n', datestr(now, 'dd.mm.yy HH:MM'));
            fprintf(fid_lf, '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n'); %#ok<CTPCT>
            fprintf(fid_lf, '\n');
            
            % Input of header
            eof_hf = false;
            while ~eof_hf
                curline = fgets(fid_hf);
                if isequal(curline,-1)
                    eof_hf = true;
                else
                    fprintf(fid_lf, '%s', curline);
                end
            end
            
            % Include figure
            fprintf(fid_lf, '\n');
            fprintf(fid_lf, '\\begin{document}\n');
            fprintf(fid_lf, '\n');
            fprintf(fid_lf, '%% Figure\n');
            fprintf(fid_lf, '\\centering\n');
            fprintf(fid_lf, '\\fbox{\n');
            fprintf(fid_lf, '  \\psfragfig{%s}\n', fig_file);
            fprintf(fid_lf, '}\n');
            fprintf(fid_lf, '\\end{document}\n');
            fprintf(fid_lf, '\n');
            fprintf(fid_lf, '%% eof\n');
            
            % Close files
            fclose(fid_hf);
            fclose(fid_lf);
            
            %% Create output
            % Run latex
            [status, result] = xsystem(['pdflatex -shell-escape --src -interaction=nonstopmode \"' latex_file '.tex\"']);
            if status
                disp(result)
                warning('PVmatlabfrag:LaTeX', 'Error while runnig latex')
            end
            
            %% Rename output
            if ismember(preview, {'pdf'})
                copyfile([latex_file '.' preview], [PV_file '.' preview], 'f')
            end
            
            %% Tidy up
            if del_files
                if ismember(output, {'eps_tex'})
                    delete([fig_file '.pdf'])
                end
                
                if ismember(output, {'pdf'})
                    delete([fig_file '.eps'])
                    delete([fig_file '.tex'])
                end
                
                delete([fig_file '-pstool.*'])
                delete([latex_file '*.*']);
            end
        end
        
        %% Latex
    elseif ismember(compiler, {'latex', 'LATEX'})
        %% Make Input check
        if ~ismember(output, {'eps_tex'})
            error('In LaTeX mode only ''eps_tex'' is support as output. Consider using: ''compiler'', ''pdflatex''.')
        end
        
        if ~ismember(preview, {'none' 'dvi', 'ps', 'pdf'})
            error('In LaTeX mode preview must be one of ''none'', ''dvi, ''ps'' or ''pdf''')
        end
        
        %% Preview
        if ismember(preview, {'dvi', 'ps', 'pdf'})
            
            %% Create Latex File
            % Open files
            fid_lf = fopen([latex_file '.tex'], 'w+');
            fid_hf = fopen(latex_header, 'r');
            
            % Print some comment
            fprintf(fid_lf, '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
            fprintf(fid_lf, '%%  LaTeX File to create matlabfrag preview               %%\n');
            fprintf(fid_lf, '%%  Created by xmf_export at %s             %%\n', datestr(now, 'dd.mm.yy HH:MM'));
            fprintf(fid_lf, '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n'); %#ok<CTPCT>
            fprintf(fid_lf, '\n');
            
            % Input of header
            eof_hf = false;
            while ~eof_hf
                curline = fgets(fid_hf);
                if isequal(curline,-1)
                    eof_hf = true;
                else
                    fprintf(fid_lf, '%s', curline);
                end
            end
            
            % Include figure
            fprintf(fid_lf, '\n');
            fprintf(fid_lf, '\\begin{document}\n');
            fprintf(fid_lf, '\n');
            fprintf(fid_lf, '%% Figure\n');
            fprintf(fid_lf, '\\centering\n');
            fprintf(fid_lf, '\\fbox{\n');
            fprintf(fid_lf, '  \\input{%s.tex}\n', fig_file);
            fprintf(fid_lf, '  \\includegraphics{%s.eps}\n', fig_file);
            fprintf(fid_lf, '}\n');
            fprintf(fid_lf, '\\end{document}\n');
            fprintf(fid_lf, '\n');
            fprintf(fid_lf, '%% eof\n');
            
            % Close files
            fclose(fid_hf);
            fclose(fid_lf);
            
            %% Create output
            % Run latex
            [status, result] = xsystem(['latex --src -interaction=nonstopmode ' latex_file]);
            if status
                disp(result)
                error('PVmatlabfrag:LaTeX', 'Error while runnig latex')
            end
            
            % Run dvips
            if ~isequal(preview, 'dvi')
                [status, result] = xsystem(['dvips -P pdf "' latex_file '.dvi"']);
                if status
                    disp(result)
                    error('PVmatlabfrag:LaTeX', 'Error while runnig dvips')
                end
            end
            
            % Run gswin32c
            if isequal(preview, 'pdf')
                %[status, result] = xsystem(['gswin32c -sPAPERSIZE=a4 -dSAFER -dBATCH -dNOPAUSE -sDEVICE=pdfwrite -sOutputFile=' latex_file '.pdf -c save pop -f ' latex_file '.ps']);
                [status, result] = xsystem(['ps2pdf ' latex_file '.ps']);
                if status
                    disp(result)
                    error('PVmatlabfrag:LaTeX', 'Error while runnig gswin32c')
                end
            end
            
            %% Rename output
            copyfile([latex_file '.' preview], [PV_file '.' preview], 'f')
            
            %% Tidy up
            if del_files
                delete('XMF_tmp*.*');
            end
            
        end
    %% Error
    else
        error('Unknown LaTeX compiler')
    end
catch e
    cd(cur_dir)
    rethrow(e)
end
cd(cur_dir)

%% eof
