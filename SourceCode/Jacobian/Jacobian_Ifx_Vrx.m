function H = Jacobian_Ifx_Vrx(node, branch, admittance, br, type)
% This function returns the Jacobian for imaginary branch currents (their 
%  derivatives) with respect to rectangular voltage variables.
%
% SYNTAX:
%   H = Jacobian_Ifx_Vrx(node, branch, admittance, br, type)
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
%   H : Jacobian matrix of imaginary branch currents for rectangular voltage
%        state variables.

%% Jacobian calculation
G = real(admittance.Y);
B = imag(admittance.Y);
Gs = real(admittance.Ys);
Bs = imag(admittance.Ys);
nmeas = length(br);                             % number current measurements
Hr = zeros(nmeas,node.num);                     % initialization submatrix derivatives wrt real voltages
Hx = zeros(nmeas,node.num);                     % initialization submatrix derivatives wrt imaginary voltages
[from, to] = Bus_of_branch(branch, br);    % terminal nodes of the branches where measurements are taken   
for i = 1:nmeas
    m = from(i);
    n = to(i);
    Hr(i,m) = -B(m,n) + Bs(m,n);                % derivative dIx/dVr(m)
    Hr(i,n) = B(m,n);                           % derivative dIx/dVr(m)
    Hx(i,m) = -G(m,n) + Gs(m,n);                % derivative dIx/dVr(m)
    Hx(i,n) = G(m,n);                           % derivative dIx/dVr(m)
end 
if type == 2                                    % if no PMUs are available delete the derivatives with respect to the first imaginary voltage
    Hx(:,1) = [];
end
H = [Hr, Hx];                                   % overall Jacobian