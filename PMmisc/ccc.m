function ccc(varargin)
% CCC Clears everything, closes everything and clears the screen
%
%   CCC by itself closes all figures and files and clears all variables and
%   the command screen. It is thus equivalent to:
%       FCLOSE all; CLOSE all; CLEAR *; CLC
%
%   CCC accepts the same arguments as the CLEAR function. You can use e.g.
%   CCC ALL, CCC VARIABLES, CCC GLOBAL, CCC FUNCTIONS as specified in the
%   CLEAR help page.
%
%   CCC -EXCEPTION prevents the function from clearing selected data. Valid
%   exceptions are: -files, -figures, -variables, -screen. Any exception 
%   can be abbreviated by their first three letters, e.g. -fig. Exceptions
%   can be combined, e.g. CCC -fig -fil.
%
%   CCC +FORCE tells CCC to use force options on the clearing commands.
%   Currently this only implies to use CLOSE ALL HIDDEN for clearing
%   figures. The force flag can be combined with all other flags. 
%
% See also: CLEAR CLOSE CLC FCLOSE


% Default options
f_files     = true;
f_figures   = true;
f_variables = true;
f_screen    = true;
f_force     = false;

% Parse additional flags
options = horzcat({''}, varargin);
if any(strncmpi(options, '-fil',4))
    f_files     = false;
end
if any(strncmpi(options, '-fig',4))
    f_figures   = false;
end
if any(strncmpi(options, '-var',4))
    f_variables = false;
end
if any(strncmpi(options, '-scr',4))
    f_screen    = false;
end
if any(strncmpi(options, '+for',4))
    f_force     = true;
end

% Remove local options from options cell
options(strncmpi(options, '-fil', 4)) = [];
options(strncmpi(options, '-fig', 4)) = [];
options(strncmpi(options, '-var', 4)) = [];
options(strncmpi(options, '-scr', 4)) = [];
options(strncmpi(options, '+for', 4)) = [];

% Do clearing!!
if f_files;                                   fclose all;                     end;
if f_figures && ~f_force;                     close  all;                     end;
if f_figures &&  f_force;                     close  all hidden;              end;
if f_variables;             evalin('caller',['clear' strjoin(options, ' ')]); end;
if f_screen;                                  clc;                            end;

