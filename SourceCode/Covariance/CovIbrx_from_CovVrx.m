function covIrx = CovIbrx_from_CovVrx(covVrx, node, branch, admittance)
% This function computes the covariance matrix of branch currents in real
%  and imaginary coordinates starting from the covariance matrix of real
%  and imaginary voltages.
%
% SYNTAX:
%   covIrx = CovIbrx_from_CovVrx(covVrx, node, branch, admittance)
%
% INPUTS:
%   covVrx : covariance matrix of the real and imaginary components of V
%
%   node : structure with the following data about the grid nodes 
%       node.num = number of the nodes in the grid.
%       node.type = matrix of cells with the following information. 
%                  -------------- --------------- ---------------   
%                 | Type of node | 1st set point | 2nd set point |
%                 |--------------|---------------|---------------|  
%                 |   'slack'    |    V (p.u.)   |  theta (rad)  |
%                 |    'PQ'      |    P (p.u.)   |    Q (p.u.)   |
%                 |    'PV'      |    P (p.u.)   |    V (p.u.)   |
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
%   admittance : structure with the following admittance matrices  ->
%       Y : admittance matrix of the grid
%       Ys : matrix with only shunt admittances (out of the diagonal)
%
% OUTPUTS:
%   covIrx : covariance matrix of the branch currents in rectangular coordinates.

%% Covariance matrix calculation (uncertainty propagation)
br = (1:1:branch.num)';
a = Jacobian_Ifr_Vrx(node, branch, admittance, br, 1);          % derivative [dIr/dVr, dIr/dVx];
b = Jacobian_Ifx_Vrx(node, branch, admittance, br, 1);          % derivative [dIx/dVr, dIx/dVx];
der = [a; b];                            % overall derivative matrix
covIrx = der * covVrx * der';            % output covariance matrix of real and imaginary currents (uncertainty propagation law)