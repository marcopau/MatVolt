function S = Calculation_powers(branch, V, I)
% This function returns the powers (both branch and nodal) given the 
%  grid data and the knowledge of the grid voltages and currents.
%
% SYNTAX:
%   S = Calculation_powers(branch, V, I)
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
%   V : structure with the vectors of the voltages in different formats
%        (mag, phase, real, imag, complex).

%   I : structure with the vectors of the currents in different formats
%        (mag, phase, real, imag, complex) for:
%       I.br1 : branch current at the sending node.
%       I.br2 : branch current at the receiving node.
%       I.inj : nodal current injection.
%
% OUTPUTS: 
%   S : structure with the vectors of the powers in different formats
%        (mag, phase, real, imag, complex) for:
%       S.br1 : power at the sending node.
%       S.br2 : power at the receiving node.
%       S.inj : power current injection.

%% Branch powers
% Powers at the sending node
S.br1.complex = V.complex(branch.start) .* conj(I.br1.complex);
S.br1 = Complex_to_all(S.br1);

% Powers at the receiving node
S.br2.complex = V.complex(branch.end) .* conj(I.br2.complex);
S.br2 = Complex_to_all(S.br2);

%% Power injections
S.inj.complex = V.complex .* conj(I.inj.complex);
S.inj = Complex_to_all(S.inj);
