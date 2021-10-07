function xmf_prepare(varargin)
% XMF_PREPARE Prepares a figure for XMF export
%
%   XMF_PREPARE() performs the actions defined by the XMF_INIT command to
%   the current figure handle.
%
%   XMF_PREPARE(H_FIG) performs these actions to the figure given in figure
%   handle H_FIG.
%
%   XMF_PREPARE(..., KEY, VALUE) passes additional KEY/VALUE pairs to the
%   actions to be performed. These overwrite the values set in the XMF_INIT
%   command.
%
%   The following key/value pairs can be used:
%       'ensuremath' = true     Sets all math symbols used in text objects
%                               with tex interpreter to math mode. This
%                               prevents errors with tex strings, that
%                               display correctly in Matlab, but are not
%                               recognized when exporting the figure to
%                               LaTeX.
%                               Note: This is not done for text data with
%                               the latex interpreter enabled, because this
%                               interpreter already needs $$ to typeset formulae. 
%                               Note: Custom UserData will NOT be overwritten!
%                               Note: Ticklabels cannot be tex strings in
%                               Matlab, so they won't be texified here
%                               either.
%                               Note: The use of special characters like
%                               #%$& will still cause problems in not-texified
%                               texts. See the 'escape' option.
%       'escape' = true         Takes care of special characters supported
%                               in Matlab text objects but not in LaTeX.
%                               This includes e.g. #%$&.
%       'protectspace' = true   Protects spaces with ~. This prevents
%                               missing spaces after TeX commands.
%       'fontsize' = ...        If this option is not empty, the font size
%                               of all text objects in the figure will be
%                               changed.
%                               Note: To retrieve the default font size, use
%                               get(0, 'DefaultTextFontsize').
%       'fontname' = ...        If this option is not empty, the font name
%                               of all text objects in the figure will be
%                               changed.
%                               Note: To retrieve the default font name, use
%                               get(0, 'DefaultTextFontname').
%       'interpreter' = ...     If this option is not empty, the interpreter
%                               of all text objects in the figure will be
%                               changed.
%                               Note: To retrieve the default font name, use
%                               get(0, 'DefaultTextInterpreter').
%
%   See also: XMF_INIT


% Read current settings structure and remember it as the source
settings = xmf_init();
settings = settings.xmf_prepare;
sources  = structfun(@(c)'xmf_init', settings, 'UniformOutput', false);

% Assign figure handle and options cell
if nargin < 1
    h_fig = gcf;
    opts  = {};
elseif ishandle(varargin{1})
    h_fig = varargin{1};
    opts  = varargin(2:end);
else
    h_fig = gcf;
    opts  = varargin;
end
    
% Process options (error checking will be done in subroutines)
for i_opt = 1:2:length(opts)-1
    settings.(lower(opts{i_opt})) = opts{i_opt+1};
    sources. (lower(opts{i_opt})) = 'passed argument';
end

% Loop all the figure tree to find and process children
handles_todo = h_fig;
while ~isempty(handles_todo)
    
    % Append suitable handles
    % Note: TickLabels cannot be texified by matlab, so it won't be
    % done here either.
    handles_todo = [handles_todo ; get(handles_todo(1), 'Children')]; %#ok<AGROW>
    if strcmp(get(handles_todo(1), 'Type'), 'axes')
        handles_todo = [handles_todo ; get(handles_todo(1), 'Title') ; get(handles_todo(1), 'XLabel') ; get(handles_todo(1), 'YLabel') ; get(handles_todo(1), 'ZLabel')]; %#ok<AGROW>
    end
    
        % Initialize options to be changed
    opt2change={};
    
    % Set font sizes
    if  ~isempty(settings.fontsize) ...
        &&  isprop(handles_todo(1), 'FontSize')
            opt2change = {opt2change{:}, 'FontSize', settings.fontsize};
    end

    % Set font names
    if   ~isempty(settings.fontname) ...
        &&  isprop(handles_todo(1), 'FontName')
            opt2change = {opt2change{:}, 'FontName', settings.fontname};
    end
    
    % Set interpreter
    if  ~isempty(settings.interpreter) ...
        &&  isprop(handles_todo(1), 'Interpreter')
            opt2change = {opt2change{:}, 'Interpreter', settings.interpreter};
            
    end
    
    % Keep postion if userdefiend
    if isfield(get(handles_todo(1)), 'Location') && strcmp(get(handles_todo(1), 'Location'), 'none')
        opt2change = {opt2change{:}, 'Position', get(handles_todo(1), 'Position')};
    end
   
    % Aply changes
    if ~isempty(opt2change)
        set(handles_todo(1), opt2change{:});
    end
    

    % Do special text treatments
    if                strcmp( get(handles_todo(1), 'Type'), 'text')                 ...            Type        is text
        &&  ( isempty(        get(handles_todo(1), 'UserData'))                     ...        and UserData    is empty
           ||~isempty(strfind(get(handles_todo(1), 'UserData'),    'xmf|'))         ...                        or set here
            )
        
        % Read string into cell array
        if iscell(get(handles_todo(1), 'String'))
            String =  get(handles_todo(1), 'String') ;
        else
            String = {get(handles_todo(1), 'String')};
        end
        
        % Escape special characters: TeX interpreter, because LaTeX already needs $...$
        if      settings.escape ...
            &&  strcmp( get(handles_todo(1), 'Interpreter'), 'tex')
            findit    = {'&'  '%'  '@' '#'  '$' };
            replaceit = {'\&' '\%' '@' '\#' '\$'};
            for i_rep = 1:length(findit)
                String= strrep(String, findit{i_rep}, replaceit{i_rep});
            end
        end % Done escape
        
        % Escape whitespace characters: TeX interpreter only
        if      settings.protectspace ...
            &&  strcmp( get(handles_todo(1), 'Interpreter'), 'tex')
            findit    = {' '};
            replaceit = {'~'};
            for i_rep = 1:length(findit)
                String= strrep(String, findit{i_rep}, replaceit{i_rep});
            end
        end % Done protectspace
        
        % Ensure math on suitable text entities: TeX interpreter, because LaTeX already needs $...$
        if      settings.ensuremath ...
            &&  strcmp( get(handles_todo(1), 'Interpreter'), 'tex')

            % Manipulate String without changing appearance 
            % 1. Set all special sequences to math mode (see help on 'String' property of Text objects)
            specials = {'\alpha' '\upsilon' '\sim' '\beta' '\phi' '\leq' '\gamma' '\chi' '\infty' '\delta' '\psi' '\clubsuit' '\epsilon' '\omega' '\diamondsuit' '\zeta' '\Gamma' '\heartsuit' '\eta' '\Delta' '\spadesuit' '\theta' '\Theta' '\leftrightarrow' '\vartheta' '\Lambda' '\leftarrow' '\iota' '\Xi' '\uparrow' '\kappa' '\Pi' '\rightarrow' '\lambda' '\Sigma' '\downarrow' '\mu' '\Upsilon' '\circ' '\nu' '\Phi' '\pm' '\xi' '\Psi' '\geq' '\pi' '\Omega' '\propto' '\rho' '\forall' '\partial' '\sigma' '\exists' '\bullet' '\varsigma' '\ni' '\div' '\taut' '\cong' '\neq' '\equiv' '\approx' '\aleph' '\Im' '\Re' '\wp' '\otimes' '\oplus' '\oslash' '\cap' '\cup' '\supseteq' '\supset' '\subseteq' '\subset' '\int' '\in' '\o' '\rfloor' '\lceil' '\nabla' '\lfloor' '\cdot' '\ldots' '\perp' '\neg' '\prime' '\wedge' '\times' '\0' '\rceil' '\surd' '\mid' '\vee' '\varpi' '\copyright' '\langle' '\rangle'};
            specials = fliplr(sort(specials));  %#ok<FLPST> % Ensure \omega before \o...
            String   = regexprep(String, ['(\' implode('|\', specials) ')'], '$$1$');
            % 2. Typeset all sub/superscripts
            String   = regexprep(String, '(_|\^)({.*?}|.)', '$$1{\\mathrm{$2}}$');
            % 3. Font/Color changes can stay as they are

            % Get horizontal alignment
            halign = get(handles_todo(1),'HorizontalAlignment');
            
            % Make table
            if length(String) > 1
                String = [ '\begin{tabular}{@{}' halign(1) '@{}}' ...
                             implode('\\', String) ...
                           '\end{tabular}' ...
                         ];
            else
                String = String{1};
            end
        end % Done ensuremath

        % If String has been changed, set "matlabfrag:" in UserData
        set(handles_todo(1), 'UserData', ['xmf|matlabfrag:' String]);

        
    end
    
    % Continue looping
    handles_todo(1) = [];
end





















