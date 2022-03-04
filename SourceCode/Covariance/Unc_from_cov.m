function unc = Unc_from_cov(cov, X, str)
% This function computes the expanded uncertainties (under Gaussian 
%  hyphothesis and coverage factor 3) of a certain vector X, given the 
%  vector itself and its covariance.
%
% SYNTAX:
%   unc = Unc_from_cov(cov, X, str)
%
% INPUTS:
%   cov : starting covariance matrix of the vector
%   X : vector whose uncertainty has to be calculated
%   str : string to indicate how to calculate the uncertainty; available
%          options are ->
%          'absolute' -> uncertainty in absolute terms
%          'per unit' -> uncertainty in relative terms (per unit)
%          'percentage' -> uncertainty in relative terms (percent)
%
% OUTPUTS:
%   unc : vector of the expanded uncertainties.

%% Uncertainty calculation
unc = 3*sqrt(diag(cov));
if strcmp(str, 'per unit')
    unc = unc./abs(X);
elseif strcmp(str, 'percentage')
    unc = 100*unc./abs(X);
end