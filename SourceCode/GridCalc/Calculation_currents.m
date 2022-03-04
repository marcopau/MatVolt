function I = Calculation_currents(branch, V, admittance)
% This function returns the currents (both branch and nodal) given the 
%  grid data and the knowledge of the node voltages.
%
% SYNTAX:
%   I = Calculation_currents(branch, V, admittance)
%
% INPUTS:
%   branch : structure with the following data about the grid branches
%       branch.num = number of branches in the grid.
%       branch.start = vector with the numerical indexes of the nodes at  
%                       the sending end of each branch.
%       branch.end = vector with the numerical indexes of the nodes at the 
%                     receiving end of each branch.
%       branch.id = vector with the numerical indexes associated to each
%                    branch.
%       branch.R : vector with the branch series resistances
%       branch.X : vector with the branch series reactances
%       branch.G : vector with branch shunt conductance
%       branch.B : vector with the branch shunt susceptance
%
%   V : structure with the vectors of the voltage in different formats
%        (mag, phase, real, imag, complex).
%
%   admittance : structure with the following admittance matrices  ->
%       Y : admittance matrix of the grid
%       Ys : matrix with only shunt admittances (out of the diagonal)
%
% OUTPUTS: 
%   I : structure with the vectors of the currents in different formats
%        (mag, phase, real, imag, complex) for:
%       I.br1 : branch current at the sending node.
%       I.br2 : branch current at the receiving node.
%       I.inj : nodal current injection.

%% Initialization vectors
Y = admittance.Y;
Ys = admittance.Ys;
Irx1 = zeros(branch.num,1);
Irx2 = zeros(branch.num,1);
Iinj = zeros(length(Y),1);
Vrx = V.complex;

%% Computation branch currents
for i = 1:branch.num
    from = branch.start(i);
    to = branch.end(i);
    Irx1(i,1) = - (Vrx(from) - Vrx(to))*Y(from,to) + Ys(from,to)*Vrx(from);     % NB: out of diagonal admittance terms are opposite (in sign) to branch admittances
    Irx2(i,1) = - (Vrx(to) - Vrx(from))*Y(to,from) + Ys(to,from)*Vrx(to);
end

% Currents at the sending node
I.br1.complex = Irx1;
I.br1 = Complex_to_all(I.br1);

% Currents at the receiving node
I.br2.complex = Irx2;
I.br2 = Complex_to_all(I.br2);

%% Computation node current injections
for i = 1:length(Y)
    from = branch.start == i;
    to = branch.end == i;
    Iinj(i,1) = sum(Irx1(from)) + sum(Irx2(to));
end
I.inj.complex = Iinj;
I.inj = Complex_to_all(I.inj);
