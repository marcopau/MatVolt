function I = Flat_start_current(num)
% This function returns the vector of flat start branch currents, with
% zeros for the current magnitudes and phase angles.
%
% SYNTAX:
%   I = Flat_start_current(num)
% 
% INPUTS:
%   num : number of the grid branches 
%
% OUTPUTS: 
%   I : structure with the vectors of the branch currents in different
%        formats (mag, phase, real, imag, complex).

%% Voltage flat start definition
I.complex = complex(zeros(num,1), zeros(num,1));
I = Complex_to_all(I);