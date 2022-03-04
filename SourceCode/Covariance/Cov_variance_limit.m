function cov = Cov_variance_limit(cov, thr)
% This function rounds the diagonal terms of the covariance matrix in input
%  to a minimum threshold limit to avoid ill-conditioning.
%
% SYNTAX:
%   cov = Cov_variance_limit(cov, thr)
%
% INPUTS & OUTPUTS:
%   cov : covariance matrix to be checked.
%   thr : threshold to be considered

%% Threshold check
for i=1:length(cov)
    if cov(i,i) < thr         % if the variance is smaller than the threshold, it will be limited to the threshold value
        cov(i,i) = thr;
    end
end