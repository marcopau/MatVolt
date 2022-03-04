function W = Weight_PMU_rect(zmag,ztheta,vmag,vtheta)
% This function returns the weighting matrix for PMU measurements expressed
%  in rectangular coordinates.
%
% SYNTAX:
%   W = Weight_PMU_rect(zmag,ztheta,vmag,vtheta)
%
% INPUTS:
%   zmag : vector of the PMU magnitude measurements.
%   ztheta : vector of the PMU angle measurements.
%   vmag : vector of the variances of the PMU magnitude measurements.
%   vtheta : vector of the variances of the PMU angle measurements.
%
% OUTPUTS:
%   W : resulting weighting matrix for the real and imaginary synchrophasor
%        measurements.

%% Covariance matrix calculation (uncertainty propagation)
a = diag(cos(ztheta));                          % derivative of phasor real part with respect to the phasor magnitude
b = diag(-zmag.*sin(ztheta));                   % derivative of phasor real part with respect to the phasor angle
c = diag(sin(ztheta));                          % derivative of phasor imaginary part with respect to the phasor magnitude
d = diag(zmag.*cos(ztheta));                    % derivative of phasor imaginary part with respect to the phasor angle
rot_mat = [a, b; c, d];                         % overall derivative matrix
Cov_in = [diag(vmag), zeros(length(vmag)); zeros(length(vmag)), diag(vtheta)];  % input covariance matrix of phasor magnitudes and angles
Cov_out = rot_mat * Cov_in * rot_mat';          % output covariance matrix of real and imaginary phasors (uncertainty propagation law)
Cov_out = Cov_variance_limit(Cov_out, 1e-12);   % possible approximation of too small terms on the diagonal to avoid ill-conditioning

%% Weighting matrix calculation
W = inv(Cov_out);                               % computation of the weighting matrix as inverse of the covariance