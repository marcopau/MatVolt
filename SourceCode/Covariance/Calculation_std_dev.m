function std_dev = Calculation_std_dev(unc, str, val)
% This function returns the standard deviation of a value given its
%  uncertainty (under the assumption of Gaussian distributed uncertainty
%  with coverage factor equal to 3).
%
% SYNTAX:
%   std_dev = Calculation_std_dev(unc, str, val)
%
% INPUTS:
%   unc : scalar or vector of the uncertainty values.
%   str : string defining if the uncertainty is in 'percent' of the reading
%          value or it is given as an absolute value
%   val : scalar of vector of the input values.
%
% OUTPUTS:
%   std_dev : resulting scalar or vector of the standard deviations.

%% Check size of input
lval = length(val);
if lval == 0
    std_dev = [];
    return
end

%% Detect type of uncertainty
if strcmp(str,'percent')
    k = 100;
elseif strcmp(str,'absolute')
    k = 1;
else
    error("Error: define the input uncertainty as 'percent' or 'absolute'")
end

%% Detect size of uncertainty input
lunc = length(unc);
if lunc == 1 && lval > 1
    unc = unc*ones(lval,1);
else
    if lunc ~=lval
        error('Error: the size of the input uncertainties and values do not match')
    end
end

%% Standard deviation computation
if strcmp(str,'percent')
    std_dev = abs((unc/(3*k)).*val);
elseif strcmp(str,'absolute')
    std_dev = (unc/(3*k));
end