function Values_node_print(node, gridval)
% This function creates a table with the electrical quantities at the nodes
%  of the electrical grid.
% 
% SYNTAX:
%   Print_bus_grid_val(node, gridval)
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
%   gridval : nested structure with all the electrical data of the grid ->
%       gridval.V : structure with the vectors of the bus voltages in 
%               different formats (mag, phase, real, imag, complex).
%
%       gridval.I : structure with the vectors of the currents in different 
%               formats (mag, phase, real, imag, complex) for:
%           I.br1 : branch current at the sending node.
%           I.br2 : branch current at the receiving node.
%           I.inj : nodal current injection.
%
%       gridval.S : structure with the vectors of the powers in different
%               formats (mag, phase, real, imag, complex) for:
%           S.br1 : power at the sending node.
%           S.br2 : power at the receiving node.
%           S.inj : power current injection.
%
% OUTPUT: 
%       Bus id : id number of the bus
%       Vabs : voltage magnitude at the bus
%       Vangle : voltage phase angle at the bus
%       P : active power injection at the bus
%       Q : reactive power injection at the bus
%       cosphi : power factor of the power injection at the bus
%       Iabs : current megnitude of the injection at the bus
%       Iangle : current phase angle of the injection at the bus

%% Create and display node results
tabnode = Values_node_create_table(node, gridval);
disp(tabnode)