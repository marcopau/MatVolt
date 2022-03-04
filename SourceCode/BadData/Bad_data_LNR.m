function bdidx = Bad_data_LNR(H, W, r, idx)
% This function checks for possible bad data in a WLS and returns the index
% of the bad data, if any. The procedure is based on the largest normalized
% residual approach.
%
% SYNTAX:
%   bdidx = Bad_data_LNR(H, W, r)
%   bdidx = Bad_data_LNR(H, W, r, idx)
% 
% INPUTS:
%   H : Jacobian of the WLS
%   W : Weighting matrix of the WLS
%   r : residual vector of the WLS
%   idx : list of virtual measurements to be removed from the bad data
%         check
%
% OUTPUTS: 
%   bdidx : index of the identified bad data (if any, otherwise empty vector)

%% Check for measurements to be removed from bad data check
if nargin == 3
    idx = [];
end

%% Bad data detection and identification
G = H'*W*H;
rcov = inv(W) - H*(G\H');
rstd = sqrt(diag(rcov));
rnorm = abs(r)./rstd;
rnorm(idx) = 0;
rnorm_max = max(rnorm);
if rnorm_max > 5
    bdidx = find(rnorm==rnorm_max);
else
    bdidx = [];
end