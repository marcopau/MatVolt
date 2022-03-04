function H = Jacobian_Vx_Zrx(Znod, bus, I)
% This function returns the Jacobian for imaginary voltages (their 
%  derivatives) with respect to branch impedance variables.
%
% SYNTAX:
%   H = Jacobian_Vx_Zrx(Znod, bus, I)
%
% INPUTS: 
%   Znod : matrix with size (num_nodes X num_branches) where, for each row
%           i, there is the list of branch impedances in the path between
%           first node of the grid and node i.
%   bus : nodes id where the real voltage measurements are taken.
%   I : structure with the vectors of the currents in different formats
%        (mag, phase, real, imag, complex).
%
% OUTPUTS:
%   H : Jacobian matrix of imaginary voltages with respect to branch 
%        impedances

%% Jacobian calculation
nmeas = length(bus);                    % number voltage measurements
branch.num = size(Znod,2);
HZr = zeros(nmeas,branch.num);          % initialization submatrix derivatives wrt real impedances
HZx = zeros(nmeas,branch.num);          % initialization submatrix derivatives wrt imaginary impedances
for i = 1:nmeas
    m = bus(i);
    idx = find(Znod(m,:));
    HZr(i,idx) = -I.imag(idx);          % derivative dVx/dZr
    HZx(i,idx) = -I.real(idx);          % derivative dVx/dZx
end
H = [HZr, HZx];                         % overall Jacobian