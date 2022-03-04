function H = Jacobian_Iix_Irx(branch, bus, type)
% This function returns the Jacobian for imaginary current injections (their 
%  derivatives) with respect to rectangular branch current variables.
%
% SYNTAX:
%   H = Jacobian_Iix_Irx(branch, bus, type)
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
%   bus : nodes id where the imaginary current measurements are taken.
%   type : type of estimator (2 if PMUs are present, 1 if no PMUs are
%           available)
%
% OUTPUTS:
%   H : Jacobian matrix of imaginary current injections for rectangular 
%        branch current state variables.

%% Jacobian calculation
nmeas = length(bus);                    % number current measurements
Hv = zeros(nmeas,type);                 % initialization submatrix derivatives with respect to both real and imaginary voltage
HIr = zeros(nmeas,branch.num);          % initialization submatrix derivatives wrt real currents
HIx = zeros(nmeas,branch.num);          % initialization submatrix derivatives wrt imaginary currents
for i = 1:nmeas
    m = bus(i);
    from = branch.start == m;           % branches departing from node m
    to = branch.end == m;               % branches arriving to node m
    HIx(i,from) = 1;                    % derivative dIx/dIx
    HIx(i,to) = - 1;                    % derivative -dIx/dIx
end
H = [Hv, HIr, HIx];                     % overall Jacobian