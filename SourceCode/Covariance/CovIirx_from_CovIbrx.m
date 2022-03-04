function covIrx = CovIirx_from_CovIbrx(covIbrx, node, branch)
% This function computes the covariance matrix of current injections in real
%  and imaginary coordinates starting from the covariance matrix of real
%  and imaginary branch currents.
%
% SYNTAX:
%   covIrx = CovIirx_from_CovIbrx(covIbrx, node, branch)
%
% INPUTS:
%   covIbrx : covariance matrix of the real and imaginary components of the
%              branch currents
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
% OUTPUTS:
%   covIrx : covariance matrix of the current injections in rectangular coordinates.

%% Covariance matrix calculation (uncertainty propagation)
bus = (1:1:node.num)';
a = Jacobian_Iir_Irx(branch, bus, 2);     % derivative [dIir/dIbr, dIir/dIbx];
b = Jacobian_Iix_Irx(branch, bus, 2);     % derivative [dIix/dIbr, dIix/dIbx];
der = [a(:,3:end); b(:,3:end)];           % overall derivative matrix
covIrx = der * covIbrx * der';            % output covariance matrix of real and imaginary currents (uncertainty propagation law)