function h = MeasFunc_I_Vrx(branch, Y, br, V)
% This function returns the measurement function h(x) for branch current  
%  magnitude measurements computed using rectangular voltage variables.
%
% SYNTAX: 
%   h = MeasFunc_I_Vrx(branch, Y, br, V)
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
%       branch.R : vector with the branch series resistances [in p.u.]
%       branch.X : vector with the branch series reactances [in p.u.]
%       branch.G : vector with branch shunt conductance [in p.u.]
%       branch.B : vector with the branch shunt susceptance [in p.u]
%
%   Y : admittance matrix of the grid.
%   br : branch id where the branch current measurements are taken.
%   V : structure with the vectors of the voltages in different formats
%        (mag, phase, real, imag, complex).
%
% OUTPUTS:
%   h : vector of the meas functions of branch current magnitudes.

%% Meas function calculation
nmeas = length(br);
h = zeros(nmeas,1);
[from, to] = Bus_of_branch(branch, br);
for i = 1:nmeas
    m = from(i);
    n = to(i);
    hre = Y.mag(m,n)*((V.real(n)-V.real(m))*cos(Y.phase(m,n)) + (V.imag(m)-V.imag(n))*sin(Y.phase(m,n)));
    him = Y.mag(m,n)*((V.real(n)-V.real(m))*sin(Y.phase(m,n)) + (V.imag(n)-V.imag(m))*cos(Y.phase(m,n)));
    h(i,1) = sqrt(hre^2 + him^2);
end