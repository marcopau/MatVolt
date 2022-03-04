function unc = Unc_from_cov_call(cov, X)
% This function calls the single functions to compute the uncertainties for 
%  a given quantity in all its formats (real, imag, mag, phase)
%
% SYNTAX:
%   unc = Unc_from_cov_call(cov, X)
%
% INPUTS:
%   cov : starting covariance matrix of the vector
%   X : vector whose uncertainty has to be calculated
%
% OUTPUTS:
%   unc : structure with the vector of the expanded uncertainties for a
%      given quantity in all its different formats (real, imag, mag, phase) 

%% Call functions for each quantity format
% Note: type of desired uncertainty output can be changed, choosing between
% 'absolute', 'per unit' and 'percentage'.
n = length(cov.rx)/2;
unc.real = Unc_from_cov(cov.rx(1:n,1:n), X.real, 'percentage');            % expanded uncertainty of real quantities
unc.imag = Unc_from_cov(cov.rx(n+1:end,n+1:end), X.imag, 'percentage');    % expanded uncertainty of imaginary quantities
unc.mag = Unc_from_cov(cov.mp(1:n,1:n), X.mag, 'percentage');              % expanded uncertainty of quantities' magnitudes
unc.phase = Unc_from_cov(cov.mp(n+1:end,n+1:end), X.phase, 'absolute');    % expanded uncertainty of quantities' phase angles