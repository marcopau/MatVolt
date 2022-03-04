function H = Jacobian_Vr_Vrx(node, bus, type)
% This function returns the Jacobian for real voltages (their derivatives)
%  with respect to rectangular voltage variables.
%
% SYNTAX:
%   H = Jacobian_Vr_Vrx(node, bus, type)
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
%   bus : nodes id where the voltage measurements are taken.
%   type : type of estimator (1 if PMUs are present, 2 if no PMUs are
%           available)
%
% OUTPUTS:
%   H : Jacobian matrix of real voltage measurements for rectangular
%        voltage state variables.

%% Jacobian calculation
nmeas = length(bus);            % number voltage measurements
Hr = zeros(nmeas,node.num);     % initialization submatrix derivatives wrt real voltages
Hx = zeros(nmeas,node.num);     % initialization submatrix derivatives wrt imaginary voltages
for i = 1:nmeas
    m = bus(i);
    Hr(i,m) = 1;                % derivatives dVr/dVr
end
if type == 2                    % if no PMUs are available delete the derivatives with respect to the first imaginary voltage
    Hx(:,1) = [];
end
H = [Hr, Hx];                   % overall Jacobian