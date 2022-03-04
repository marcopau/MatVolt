function covSb = CovSb_from_CovVrx(covVrx, V, node, branch, admittance, idx)
% This function computes the covariance matrix of branch active and 
%  reactive powers starting from the covariance matrix of real and
%  imaginary voltages.
%
% SYNTAX:
%   covSb = CovSb_from_CovVrx(covVrx, V, node, branch, admittance, idx)
%
% INPUTS:
%   covVrx : covariance matrix of the real and imaginary components of V
%
%   V : structure with the vectors of the SE voltage results in different
%        formats (mag, phase, real, imag, complex).
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
%   idx : index to differentiate powers at the sending (idx=1) or receiving
%          node (idx=2).
%
% OUTPUTS:
%   covSb : covariance matrix of the branch powers in rectangular coordinates.

%% Covariance matrix calculation (uncertainty propagation)
if idx == 1
    br = (1:1:branch.num)';
elseif idx == 2
    br = -(1:1:branch.num)';
else
    error("idx variable should be either 1 or 2. See 'help CovSb_from_CovVrx' for more details")
end
a = Jacobian_P_Vrx(V, node, branch, admittance, br, 1);          % derivative [dP/dVr, dP/dVx];
b = Jacobian_Q_Vrx(V, node, branch, admittance, br, 1);          % derivative [dQ/dVr, dQ/dVx];
der = [a; b];                            % overall derivative matrix
covSb = der * covVrx * der';            % output covariance matrix of real and imaginary currents (uncertainty propagation law)