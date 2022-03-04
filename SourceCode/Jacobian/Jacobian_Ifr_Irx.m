function H = Jacobian_Ifr_Irx(branch, brid, type)
% This function returns the Jacobian for real branch currents (their 
%  derivatives) with respect to rectangular branch current variables.
%
% SYNTAX:
%   H = Jacobian_Ifr_Irx(branch, brid, type)
%
% INPUTS: 
%   branch : structure with the following data about the grid branches 
%       branch.num = number of branches in the grid.
%       branch.start = vector with the numerical indexes of the nodes at  
%                       the sending end of each branch.
%       branch.end = vector with the numerical indexes of the nodes at the 
%                     receiving end of each branch.
%       branch.id = vector with the numerical indexes associated to each
%                    branch.
%       branch.R : vector with the branch series resistances [in p.u.]
%       branch.X : vector with the branch series reactances [in p.u.]
%       branch.G : vector with branch shunt conductance [in p.u.]
%       branch.B : vector with the branch shunt susceptance [in p.u]
%
%   brid : branch id where the real current measurements are taken.
%   type : type of estimator (2 if PMUs are present, 1 if no PMUs are
%           available)
%
% OUTPUTS:
%   H : Jacobian matrix of real branch currents for rectangular branch
%        current state variables.

%% Jacobian calculation
nmeas = length(brid);                   % number current measurements
Hv = zeros(nmeas,type);                 % initialization submatrix derivatives with respect to both real and imaginary voltage
HIr = zeros(nmeas,branch.num);          % initialization submatrix derivatives wrt real currents
HIx = zeros(nmeas,branch.num);          % initialization submatrix derivatives wrt imaginary currents
for i = 1:nmeas
    m = brid(i);
    if m > 0
        HIr(i,m) = 1;                   % derivative dIr/dIr
    elseif m < 0
        HIr(i,-m) = -1;                 % derivative -dIr/dIr
    end
end
H = [Hv, HIr, HIx];                     % overall Jacobian