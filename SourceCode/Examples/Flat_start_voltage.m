function V = Flat_start_voltage(num)
% This function returns the vector of flat start voltages, with ones for
% the voltage magnitudes and zeros for the phase angles.
%
% SYNTAX:
%   V = Flat_start_voltage(num)
% 
% INPUTS:
%   num : number of the grid nodes 
%
% OUTPUTS: 
%   V : structure with the vectors of the voltages in different formats
%        (mag, phase, real, imag, complex).

%% Voltage flat start definition
V.complex = complex(ones(num,1), zeros(num,1));
V = Complex_to_all(V);
