function [dX, epsilon, r] = WLS_calc(z, h, H, W)
% This function computes an iteration of the non linear WLS following the
%  Newton Raphson method.
%
% SYNTAX: 
%   [dX, epsilon] = WLS_calc(z, h, H, W)
%
% INPUTS: 
%   z : input measurement vector.
%   h : vector of the measurement as functions of the WLS state variables.
%   H : Jacobian matrix of the measurement functions 'h'.
%   W : weighting matrix of the measurements.
%
% OUTPUTS:
%   dX : updating vector of the state variables of a state vector X.
%   epsilon : largest value of the updating state vector used for the
%              check of the WLS convergence.
%   r : vector of the measurement residuals

%% Execution of the WLS normal equations
r = z-h;                    % computation measurement residuals
g = H'*W*r;                 % computation right term of the normal equation
Gm = H'*W*H;                % computation Gain matrix
dX = Gm\g;                  % WLS normal equation
epsilon = max(abs(dX));     % value to check for convergence