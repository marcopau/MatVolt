function [branch, node] = Network_95_nodes_data(base)
% This function creates the structure arrays with the data (in p.u.) of a 
%  95-bus grid (single phase equivalent model)
% The grid and its data are extracted from the thesis available here:
%  https://repositorio-aberto.up.pt/bitstream/10216/59575/2/Texto%20integral.pdf
%
% SYNTAX:
%   [branch, node] = Network_95_nodes_data(base)
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
node.num = 95;
node.grid_name = 'Network_uk95bus';         % Give a name to the grid (this is used when saving results)
branch.grid_name = node.grid_name;          % Same name of the grid available also under the branch structure

%% Branch data definition
branch.start = [1, 2, 1, 4, 5, 5, 7, 7, 9, 9, 11, 12, 13, 13, 15, 15, 17, 17, 19, 20, ...
                19, 22, 23, 24, 25, 25, 27, 11, 29, 29, 31, 31, 33, 34, 33, 36, 37, 38, 39, 37, ...
                41, 42, 43, 43, 45, 46, 47, 48, 48, 50, 50, 52, 52, 42, 55, 56, 56, 58, 55, 60, ...
                61, 62, 61, 64, 65, 65, 67, 68, 69, 69, 71, 72, 73, 74, 74, 60, 77, 78, 79, 80, ...
                78, 82, 82, 84, 85, 86, 84, 88, 89, 90, 91, 92, 93, 94]';
branch.end = [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, ...
              22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, ...
              42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, ...
              62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, ...
              82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95]';
branch.num = length(branch.start);
branch.id = (1:1:branch.num)';
          
% Branch impedances (R+jX); 
branch.R = [0.05489, 0.03881, 0.04879, 0.09755, 0.17322, 0.21, 0.24251, 0.2586, 0.34645, 0.1293, 0.30169, 0.19395, ...
     0.17322, 0.23705, 0.20787, 0.2586, 0.13858, 0.1293, 0.1724, 0.10775, 0.2155, 0.19395, 0.30169, 0.09, ...
     0.13161, 0.36, 0.12, 0.295, 0.20787, 0.354, 0.24251, 0.27716, 0.2586, 0.3118, 0.11149, 0.34612, 0.15608, ...
     0.22298, 0.2135, 0.34479, 0.1293, 0.118, 0.20787, 0.236, 0.177, 0.09401, 0.177, 0.236, 0.354, 0.354, ...
     0.27716, 0.2135, 0.53374, 0.1724, 0.20787, 0.27716, 0.41574, 0.27716, 0.30169, 0.36517, 0.17322, 0.3118, ...
     0.14607, 0.25562, 0.20787, 0.18258, 0.29213, 0.25562, 0.09401, 0.4382, 0.2191, 0.07521, 0.14607, 0.29213, ...
     0.40168, 0.2586, 0.1293, 0.18258, 0.29213, 0.4382, 0.2155, 0.1293, 0.19395, 0.27716, 0.48502, 0.22621, ...
     0.2586, 0.06465, 0.27244, 0.16346, 0.0862, 0.15085, 0.27244, 0.49039]'*(11^2/100)/base.Z; 
branch.X = [0.0569, 0.104, 0.05058, 0.33284, 0.07589, 0.203, 0.10624, 0.17673, 0.15178, 0.08836, 0.20618, 0.13255, ...
     0.07589, 0.172, 0.09107, 0.17673, 0.06071, 0.08836, 0.11782, 0.07364, 0.14727, 0.13255, 0.20618, 0.087, ...
     0.05033, 0.348, 0.116, 0.15, 0.09107, 0.18, 0.10624, 0.12142, 0.17673, 0.1366, 0.07376, 0.20653, 0.10326, ...
     0.14752, 0.09126, 0.23564, 0.08836, 0.06, 0.09107, 0.12, 0.09, 0.03595, 0.09, 0.12, 0.18, 0.18, 0.12142, ...
     0.09126, 0.22816, 0.11782, 0.09107, 0.12142, 0.18213, 0.12142, 0.20618, 0.15244, 0.07589, 0.1366, 0.06098, ...
     0.10671, 0.09107, 0.07622, 0.12195, 0.10671, 0.03595, 0.18293, 0.09146, 0.02876, 0.06098, 0.12195, 0.16768, ...
     0.17673, 0.08836, 0.07622, 0.12195, 0.17673, 0.14727, 0.08836, 0.13255, 0.12142, 0.21249, 0.04686, 0.17673, ...
     0.04418, 0.04012, 0.02407, 0.05891, 0.10309, 0.04012, 0.07222]'*(11^2/100)/base.Z;

% Shunt admittances (G+jB) are often negligible at distribution level, and here they are equal to zero.
branch.G = zeros(branch.num,1);
branch.B = zeros(branch.num,1);
     
%% Node data definition
% Injection powers for all the nodes, except for the slack bus (node 1). 
% Power values are here provided in MW.
% Positive values are for the power injected by generators.
% Negative values are for the power consumed by the loads.
slackV = 1.00;
P = - [0, 0.82092, 0, 0, 0.01461, 0, 0.03046, 0, 0.02805, 0, 0.00487, 0, 0.00487, 0, 0.01569, 0, 0.01316, 0, 0, ...
     0.05754, 0.05725, 0.02777, 0.0292, 0, 0.01464, 0.6776, -0.675, 0, 0.02632, 0, 0.01831, 0, 0.0483, 0.03407, ...
     0.02777, 0, 0.05605, 0.11734, 0.00733, 0.01098, 0, 0, 0.03167, 0.05264, 0, 0, 0, 0.01461, 0, 0.01562, 0, ...
     0.03167, 0.04493, 0, 0, 0.00779, 0.00876, 0.00733, 0.02777, 0, 0.01461, 0.01461, 0.01783, 0, 0.02681, 0.0292, ...
     0.02734, 0, 0.03407, 0.01363, 0, 0, 0, 0.01266, 0.05078, 0, 0, 0, 0, 0.05359, 0, 0.025, 0, 0.08578, 0, 0.09698, ...
     0.04563, 0, 0.13277, 0, 0.0561, 0, 0.04806, -0.675]'*1e6/(base.S);
Q = - [0, 0.14346, 0, 0, 0.00208, 0, 0.00434, 0, 0.004, 0, 0.00069, 0, 0.00069, 0, 0.00516, 0, 0.00224, 0, 0, 0.00969, ...
     0.00817, 0.00432, 0.00416, 0, 0.00209, 0.22267, 0.2219, 0, 0.00449, 0, 0.00261, 0, 0.00762, 0.00486, 0.00432, ...
     0, 0.00799, 0.02783, 0.00104, 0.00156, 0, 0, 0.00451, 0.00899, 0, 0, 0, 0.00208, 0, 0.00259, 0, 0.00451, ...
     0.00863, 0, 0, 0.00111, 0.00124, 0.00104, 0.00432, 0, 0.00208, 0.00208, 0.00328, 0, 0.00381, 0.00416, 0.005, ...
     0, 0.00486, 0.00194, 0, 0, 0, 0.00181, 0.00982, 0, 0, 0, 0, 0.00764, 0, 0.005, 0, 0.01897, 0, 0.01456, 0.01, ...
     0, 0.02485, 0, 0.00799, 0, 0.00796, 0.2219]'*1e6/(base.S);

node.type = cell(node.num,3);
node.type{1,1} = 'slack';
node.type{1,2} = slackV;
node.type{1,3} = 0;
for i = 2:node.num
    node.type{i,1} = 'PQ';
    node.type{i,2} = P(i-1);
    node.type{i,3} = Q(i-1);
end