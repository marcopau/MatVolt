function H = Jacobian_I_Vrx(node, branch, Y, br, type, V)
% This function returns the Jacobian for branch current magnitudes (their 
%  derivatives) with respect to rectangular voltage variables.
%
% SYNTAX:
%   H = Jacobian_I_Irx(node, branch, Y, br, type, V)
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
%   Y : admittance matrix of the grid.
%   br : branch id where the branch current measurements are taken.
%   type : type of estimator (1 if PMUs are present, 2 if no PMUs are
%           available)
%   V : structure with the vectors of the voltages in different formats
%        (mag, phase, real, imag, complex).
%
% OUTPUTS:
%   H : Jacobian matrix of branch current magnitudes for rectangular voltage
%        state variables.

%% Jacobian calculation
nmeas = length(br);             % number current measurements
Hr = zeros(nmeas,node.num);     % initialization submatrix derivatives wrt real voltages
Hx = zeros(nmeas,node.num);     % initialization submatrix derivatives wrt imaginary voltages
[from, to] = Bus_of_branch(branch, br);    % terminal nodes of the branches where measurements are taken    
for i = 1:nmeas
    m = from(i);
    n = to(i);
    hre = Y.mag(m,n)*((V.real(n)-V.real(m))*cos(Y.phase(m,n)) + (V.imag(m)-V.imag(n))*sin(Y.phase(m,n)));
    him = Y.mag(m,n)*((V.real(n)-V.real(m))*sin(Y.phase(m,n)) + (V.imag(n)-V.imag(m))*cos(Y.phase(m,n)));
    h = sqrt(hre^2 + him^2);
    Hr(i,m) = - Y.mag(m,n)*(cos(Y.phase(m,n))*hre + sin(Y.phase(m,n))*him)/h;       % derivatives dI/dVr(m)
    Hr(i,n) = - Hr(i,m);                                                            % derivatives dI/dVr(n)
    Hx(i,n) = Y.mag(m,n)*(cos(Y.phase(m,n))*him - sin(Y.phase(m,n))*hre)/h;         % derivatives dI/dVx(m)
    Hx(i,m) = - Hx(i,n);                                                            % derivatives dI/dVx(n)
end
if type == 2                    % if no PMUs are available delete the derivatives with respect to the first imaginary voltage
    Hx(:,1) = [];
end
H = [Hr, Hx];                   % overall Jacobian