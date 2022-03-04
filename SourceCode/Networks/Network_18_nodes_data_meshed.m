function [branch, node] = Network_18_nodes_data_meshed(base)
% This function creates the structure arrays with the data (in p.u.) of an  
%  18-bus grid (single phase equivalent model).
% This is a modified version of the grid taken from the paper:
%  https://doi.org/10.1109/PES.2009.5275373 
%
% SYNTAX:
%   [branch, node] = Network_18_nodes_data_meshed(base)
%
% INPUTS:
%   base : structure with the following base (per unit) values ->
%       base.S = base power
%       base.V = base voltage
%       base.I = base current
%       base.Z = base impedance
%       base.Y = base admittance
% 
% OUTPUTS:
%   branch : structure with the following data about the grid branches
%       branch.num = number of branches in the grid
%       branch.start = vector with the numerical indexes of the nodes at  
%                      the sending end of each branch
%       branch.end = vector with the numerical indexes of the nodes at the 
%                    receiving end of each branch
%       branch.id = vector with the numerical indexes associated to each
%                    branch
%       branch.R : vector with the branch series resistances [in p.u.]
%       branch.X : vector with the branch series reactances [in p.u.]
%       branch.G : vector with branch shunt conductance [in p.u.]
%       branch.B : vector with the branch shunt susceptance [in p.u]
%
%   node : structure with the following data about the grid nodes
%       node.num = number of the nodes in the grid
%       node.type = matrix of cells with the following information 
%                  -------------- --------------- ---------------   
%                 | Type of node | 1st set point | 2nd set point |
%                 |--------------|---------------|---------------|  
%                 |   'slack'    |    V (p.u.)   |  theta (rad)  |
%                 |    'PQ'      |    P (p.u.)   |    Q (p.u.)   |
%                 |    'PV'      |    P (p.u.)   |    V (p.u.)   |

%% Starting data  
node.num = 18;
node.grid_name = 'Grid_18bus_meshed';         % Give a name to the grid (this can be used when saving results)
branch.grid_name = node.grid_name;            % Same name of the grid available also under the branch structure

%% Branch data definition
branch.start = [1, 2, 3, 4, 5, 6, 6, 8, 9, 10, 11, 11, 13, 4, 15, 16, 16, 18, 18, 2, 17]';
branch.end = [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 14, 8, 15, 14]';
branch.num = length(branch.start);
branch.id = (1:1:branch.num)';

% Branch impedances (R+jX); 
% Shunt admittances (G+jB) are often negligible at distribution level, and here they are equal to zero.
branch.R = [0.0000, 0.0174, 0.0001, 0.0052, 0.0003, 0.0010, 0.0017, 0.0022, 0.0001, 0.0016, 0.0007, 0.0299, 0.0010, 0.0025, 0.0011, 0.0034, 0.0013, 0.0040, 0.0020, 0.0010, 0.0010]'*(11^2/10)/base.Z;
branch.X = [0.1000, 0.0085, 0.0001, 0.0028, 0.0002, 0.0010, 0.0008, 0.0011, 0.0000, 0.0008, 0.0003, 0.0081, 0.0010, 0.0007, 0.0003, 0.0009, 0.0004, 0.0015, 0.0005, 0.0002, 0.0002]'*(11^2/10)/base.Z;
branch.G = zeros(branch.num,1);
branch.B = zeros(branch.num,1);

%% Node data definition
% Injection powers for all the nodes, except for the slack bus (node 1). 
% Power values are here provided in MW.
% Positive values are for the power injected by generators.
% Negative values are for the power consumed by the loads.
slackV = 1.00;
P = -[0.1, 0.3, 0, 0.4, 0, -2.0, 0, 0.8, 0.8, 0, 0.4, 0, -5.0, 0, 0, 0.1, 0.5]'*1e6/(base.S);
Q = -[0.1, 0.1, 0, 0.2, 0, -0.6, 0, 0.4, 0.4, 0, 0.2, 0, -2.0, 0, 0, 0.1, 0.3]'*1e6/(base.S);nknkl 

node.type = cell(node.num,3);
node.type{1,1} = 'slack';
node.type{1,2} = slackV;
node.type{1,3} = 0;
for i = 2:node.num
    node.type{i,1} = 'PQ';
    node.type{i,2} = P(i-1);
    node.type{i,3} = Q(i-1);
end