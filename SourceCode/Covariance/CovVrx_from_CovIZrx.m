function covVrx = CovVrx_from_CovIZrx(cov, branch, Znod, I)
% This function computes the covariance matrix of bus voltages in real
%  and imaginary coordinates starting from the covariance matrix of real
%  and imaginary currents and impedances.
%
% SYNTAX:
%   covVrx = CovVrx_from_CovIZrx(cov, branch, Znod)
%
% INPUTS:
%   cov : covariance matrix of the augmented branch current state vector 
%       (note that this also includes the voltages at a reference bus and
%       then the branch impedances in real and imaginary part)
%
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
%   Znod : matrix with size (num_nodes X num_branches) where, for each row
%           i, there is the list of branch impedances in the path between
%           first node of the grid and node i.
%
%   I : structure with the vectors of the currents in different formats
%        (mag, phase, real, imag, complex).
%
% OUTPUTS:
%   covVrx : covariance matrix of the voltages in rectangular coordinates.

%% Covariance matrix calculation (uncertainty propagation)
bus = (1:1:size(Znod,1))';
a = Jacobian_Vr_Irx(branch, Znod, bus, 2);      % derivative [dVr/dVr1, dVr/dVx1, dVr/dIr, dVr/dIx];
b = Jacobian_Vr_Zrx(Znod, bus, I);              % derivative [dVr/dR, dVr/dX];
c = Jacobian_Vx_Irx(branch, Znod, bus, 2);      % derivative [dVx/dVr1, dVx/dVx1, dVx/dIr, dVx/dIx];
d = Jacobian_Vx_Zrx(Znod, bus, I);              % derivative [dVx/dR, dVx/dX];
der = [a, b; c, d];                             % overall derivative matrix
covVrx = der * cov * der';                      % output covariance matrix of real and imaginary currents (uncertainty propagation law)