function W = Weight_pwr2curr(V,bus,vP,vQ)
% This function returns the weighting matrix for equivalent currents
%  (in rectangular coordinates) computed from starting powers.
%
% SYNTAX:
%   W = Weight_pwr2curr(V,bus,vP,vQ)
%
% INPUTS:
%   V : structure with the vectors of the voltages in different formats
%        (mag, phase, real, imag, complex).
%   bus : vector of the nodes where the power measurements are taken.
%   vP : vector of the variances of the active power measurements.
%   vQ : vector of the variances of the reactive power measurements.
%
% OUTPUTS:
%   W : resulting weighting matrix for the real and imaginary equivalent
%        current measurements.

%% Covariance matrix calculation (uncertainty propagation)
a = diag(cos(V.phase(bus))./V.mag(bus));        % derivative of Ir with respect to P (changed in sign is the derivative of Ix with respect to Q)
b = diag(sin(V.phase(bus))./V.mag(bus));        % derivative of Ir with respect to Q (it is also the derivative of Ix with respect to P)
rot_mat = [a, b; b, -a];                        % overall derivative matrix
Cov_in = diag([vP;vQ]);                         % input covariance matrix for the active and reactive powers
Cov_out = rot_mat * Cov_in * rot_mat';          % output covariance matrix for the real and imaginary currents (uncertainty propagation law)
Cov_out = Cov_variance_limit(Cov_out, 1e-12);   % possible approximation of too small terms on the diagonal to avoid ill-conditioning

%% Weighting matrix calculation
W = inv(Cov_out);                               % computation of the weighting matrix as inverse of the covariance