function admittance = Ymatrix(branch, node)
% This function returns the admittance matrix of an electrical grid
%
% SYNTAX:
%   admittance = Ymatrix(branch, node)
%
% INPUTS:
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
%
% OUTPUTS:
%   admittance : structure with the following admittance matrices  ->
%       Y : overall admittance matrix of the grid
%       Ys : matrix with only shunt admittances (out of the diagonal)

%% Branch impedance data processing
Z = complex(branch.R,branch.X);         % branch series impedance
S = complex(branch.G,branch.B);         % branch shunt admittance
C = 1./Z;                               % branch series admittance

%% Admittance matrix calculation
Y = zeros(node.num);                    % initialization Y matrix
Ys = zeros(node.num);                   % initialization Ys matrix
for L = 1:branch.num
    i = branch.start(L);
    j = branch.end(L);
    Y(i,j) = -C(L);                     % computation of the terms out of the main diagonal
    Y(j,i) = Y(i,j);
	Y(i,i) = Y(i,i) + C(L) + S(L);      % computation of the terms in the main diagonal
	Y(j,j) = Y(j,j) + C(L) + S(L);
	Ys(i,j) = S(L);                     % computation terms Ys matrix
	Ys(j,i) = S(L);
end
admittance.Y = Y;
admittance.Ys = Ys;