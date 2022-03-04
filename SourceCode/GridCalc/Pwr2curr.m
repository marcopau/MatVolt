function [Ir, Ix] = Pwr2curr(P, Q, bus, V)
% This function returns the equivalent current measurements (rectangular
%   coordinates) computed from starting power measurements.
%
% SYNTAX:
%   [Ir, Ix] = Pwr2curr(P, Q, bus, V)
%
% INPUTS:
%   P : vector of the active power measurements.
%   Q : vector of the reactive power measurements.
%   bus : vector of the nodes where the power measurements are taken.
%   V : structure with the vectors of the voltages in different formats
%        (mag, phase, real, imag, complex).
%
% OUTPUTS:
%   Ir : vector of the real equivalent current measurements.
%   Ix : vector of the imaginary equivalent current measurements.

%% Computation equivalent current measurements
Ir = (P.*V.real(bus)+Q.*V.imag(bus))./(V.mag(bus).^2);
Ix = (P.*V.imag(bus)-Q.*V.real(bus))./(V.mag(bus).^2);