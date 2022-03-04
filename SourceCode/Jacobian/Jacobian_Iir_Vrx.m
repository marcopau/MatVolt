function H = Jacobian_Iir_Vrx(node, Y, bus, type)
% This function returns the Jacobian for real current injections (their 
%  derivatives) with respect to rectangular voltage variables.
%
% SYNTAX:
%   H = Jacobian_Iir_Vrx(node, Y, bus, type)
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
%   Y : admittance matrix of the grid.
%   bus : nodes id where the real current measurements are taken.
%   type : type of estimator (1 if PMUs are present, 2 if no PMUs are
%           available)
%
% OUTPUTS:
%   H : Jacobian matrix of real current injections for rectangular voltage
%        state variables.

%% Jacobian calculation
nmeas = length(bus);            % number current measurements
Hr = zeros(nmeas,node.num);     % initialization submatrix derivatives wrt real voltages
Hx = zeros(nmeas,node.num);     % initialization submatrix derivatives wrt imaginary voltages
for i = 1:nmeas
    m = bus(i);
    Hr(i,:) = Y.real(m,:);      % derivative dIr/dVr
    Hx(i,:) = - Y.imag(m,:);    % derivative dIr/dVx
end
if type == 2                    % if no PMUs are available delete the derivatives with respect to the first imaginary voltage
    Hx(:,1) = [];
end
H = [Hr, Hx];                   % overall Jacobian