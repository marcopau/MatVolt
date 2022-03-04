function H = Jacobian_Ifr_Vrx(node, branch, admittance, br, type)
% This function returns the Jacobian for real branch currents (their 
%  derivatives) with respect to rectangular voltage variables.
%
% SYNTAX:
%   H = Jacobian_Ifr_Vrx(node, branch, admittance, br, type)
%
% INPUTS: 
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
%   br : branch id where the branch current measurements are taken.
%   type : type of estimator (1 if PMUs are present, 2 if no PMUs are
%           available)
%
% OUTPUTS:
%   H : Jacobian matrix of real branch currents for rectangular voltage
%        state variables.

%% Jacobian calculation
G = real(admittance.Y);
B = imag(admittance.Y);
Gs = real(admittance.Ys);
Bs = imag(admittance.Ys);
nmeas = length(br);                             % number current measurements
Hr = zeros(nmeas,node.num);                     % initialization submatrix derivatives wrt real voltages
Hx = zeros(nmeas,node.num);                     % initialization submatrix derivatives wrt imaginary voltages
[from, to] = Bus_of_branch(branch, br);    % find terminal nodes of the branches with the measurements
for i = 1:nmeas
    m = from(i);
    n = to(i);
    Hr(i,m) = -G(m,n) + Gs(m,n);                % derivative dIr/dVr(m)
    Hr(i,n) = G(m,n);                           % derivative dIr/dVr(n)
    Hx(i,m) = B(m,n) - Bs(m,n);                 % derivative dIr/dVx(m)
    Hx(i,n) = -B(m,n);                          % derivative dIr/dVx(n)
end
if type == 2                                    % if no PMUs are available delete the derivatives with respect to the first imaginary voltage
    Hx(:,1) = [];
end
H = [Hr, Hx];                                   % overall Jacobian