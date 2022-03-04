function H = Jacobian_Q_Vrx(V, node, branch, admittance, br, type)
% This function returns the Jacobian for active powers (their derivatives)
%  with respect to rectangular voltage variables.
%
% SYNTAX:
%   H = Jacobian_Q_Vrx(V, node, branch, admittance, br, type)
%
% INPUTS: 
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
Bs = imag(admittance.Ys);
nmeas = length(br);                             % number power measurements
Hr = zeros(nmeas,node.num);                     % initialization submatrix derivatives wrt real voltages
Hx = zeros(nmeas,node.num);                     % initialization submatrix derivatives wrt imaginary voltages
[from, to] = Bus_of_branch(branch, br);    % find terminal nodes of the branches with the measurements
for i = 1:nmeas
    m = from(i);
    n = to(i);
    Hr(i,m) = B(m,n)*(2*V.real(m)-V.real(n)) - G(m,n)*V.imag(n) - 2*Bs(m,n)*V.real(m);   % derivative dQ/dVr(m)
    Hr(i,n) = -B(m,n)*V.real(m) + G(m,n)*V.imag(m);                                        % derivative dQ/dVr(n)
    Hx(i,m) = B(m,n)*(2*V.imag(m)-V.imag(n)) + G(m,n)*V.real(n) - 2*Bs(m,n)*V.imag(m);   % derivative dQ/dVx(m)
    Hx(i,n) = -B(m,n)*V.imag(m) - G(m,n)*V.real(m);                                        % derivative dQ/dVx(n)
end
if type == 2                                    % if no PMUs are available delete the derivatives with respect to the first imaginary voltage
    Hx(:,1) = [];
end
H = [Hr, Hx];                                   % overall Jacobian