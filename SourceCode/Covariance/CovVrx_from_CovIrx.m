function covVrx = CovVrx_from_CovIrx(covIrx, branch, Znod)
% This function computes the covariance matrix of bus voltages in real
%  and imaginary coordinates starting from the covariance matrix of real
%  and imaginary branch currents.
%
% SYNTAX:
%   covVrx = CovVrx_from_CovIrx(covIrx, branch, Znod)
%
% INPUTS:
%   covIrx : covariance matrix of the branch current state vector (note
%       that this also includes the voltages at a reference bus) 
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
% OUTPUTS:
%   covVrx : covariance matrix of the voltages in rectangular coordinates.

%% Covariance matrix calculation (uncertainty propagation)
bus = (1:1:size(Znod,1))';
a = Jacobian_Vr_Irx(branch, Znod, bus, 2);      % derivative [dVr/dVr1, dVr/dVx1, dVr/dIr, dVr/dIx];
b = Jacobian_Vx_Irx(branch, Znod, bus, 2);      % derivative [dVx/dVr1, dVx/dVx1, dVx/dIr, dVx/dIx];
der = [a; b];                                   % overall derivative matrix
covVrx = der * covIrx * der';                   % output covariance matrix of real and imaginary currents (uncertainty propagation law)