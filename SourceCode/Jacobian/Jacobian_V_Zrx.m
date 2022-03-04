function H = Jacobian_V_Zrx(Znod, bus, I, V)
% This function returns the Jacobian for voltage magnitudes (their 
%  derivatives) with respect to branch impedance variables.
%
% SYNTAX:
%   H = Jacobian_V_Zrx(Znod, bus, I, V)
%
% INPUTS: 
%   Znod : matrix with size (num_nodes X num_branches) where, for each row
%           i, there is the list of branch impedances in the path between
%           first node of the grid and node i.
%   bus : nodes id where the real voltage measurements are taken.
%   I : structure with the vectors of the currents in different formats
%        (mag, phase, real, imag, complex).
%   V : structure with the vectors of the voltages in different formats
%        (mag, phase, real, imag, complex).
%
% OUTPUTS:
%   H : Jacobian matrix of voltage magnitudes with respect to branch 
%        impedances.

%% Jacobian calculation
nmeas = length(bus);                    % number voltage measurements
branch.num = size(Znod,2);
HZr = zeros(nmeas,branch.num);          % initialization submatrix derivatives wrt real impedances
HZx = zeros(nmeas,branch.num);          % initialization submatrix derivatives wrt imaginary impedances
for i = 1:nmeas
    m = bus(i);
    idx = find(Znod(m,:));
    HZr(i,idx) = -I.real(idx)*cos(V.phase(m)) - I.imag(idx)*sin(V.phase(m));        % derivative dV/dZr
    HZx(i,idx) = -I.real(idx)*sin(V.phase(m)) + I.imag(idx)*cos(V.phase(m));        % derivative dV/dZx
end
H = [HZr, HZx];                         % overall Jacobian