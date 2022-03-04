function val = Complex_to_all(val)
% This function adds to a structure array containing a field "complex"
% (having complex values in it) the quantities of the associated fields
% 'real', 'imag', 'mag' and 'phase'.
%
% SYNTAX:
%   val = Complex_to_all(val)
%
% INPUTS:
%   val : it must be a structure containing the 'complex' field.
%
% OUTPUTS:
%   val : same structure as in input with the additional (or updated)  
%          fields 'real', 'imag', 'mag' and 'phase'.

%% Computation other fields
val.mag = abs(val.complex);
val.phase = angle(val.complex);
val.real = real(val.complex);
val.imag = imag(val.complex);