% STROVERLAPI checks for case insensitive string overlap
%   A=STROVERLAPI(STRA,STRB) checks for each string in STRA it it is part of
%   any string in STRB or any string in STRB is part of the respective string
%   in STRA (case insensitive). STRA and STRB can be strings or cell-arrays 
%   of strings. The logical return array A has the same number of elements
%   as number of strings in STRA.
%
%   See also STRFIND,STROVERLAP

% REVISIONS:    2014-04-16 first implementation
% 
% Contact       pusch.research@gmail.com
%
function a=stroverlapi(strA,strB)

a=stroverlap(upper(strA),upper(strB));