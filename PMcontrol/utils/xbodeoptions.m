function p = xbodeoptions(varargin)
%XBODEOPTIONS An extenstion of the standard BODEOPTIONS command
%
% P = XBODEOPTIONS 
%             ist the same like P = BODEOPTIONS
% P = XBODEOPTIONS(KEY1, VALUE1, ...)
%             changes addtionally the options specified by KEY1, VALUE1, ...

% REVISIONS:    2012-04-20 Inital Releas (knob_an)
%
% Contact       Andreas Knoblach,  Andreas.Knoblach@dlr.de
% Copyright (C) 2008-2010 DLR Robotics and Mechatronics         __/|__
%                                                              /_/_/_/  
%                                                                |/ DLR

%% Function
p = bodeoptions;
set(p, varargin{:});

%% eof
