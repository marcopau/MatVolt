function val = Conversion_from_pu(val, base)
% This function converts per unit data into the actual values and the phase 
%  angles in degrees.
% 
% SYNTAX:
%   val = Conversion_from_pu(val, base)
%
% INPUTS:
%   val : structure with the vectors of the electrical quantity in
%          different formats (mag, phase, real, imag, complex)
% 
%   base : scalar base value for the considered electrical quantity
%
% OUTPUTS:
%   val : structure with the vectors of the converted electrical quantity
%          in different formats (mag, phase, real, imag, complex)

%% Conversion from per unit to actual values
val.mag = val.mag*base;
val.phase = val.phase*180/pi;     % phase angles are converted in degrees
val.real = val.real*base;
val.imag = val.imag*base;
val.complex = val.complex*base;