function H = Jacobian_V_Irx(branch, Znod, bus, type, V)
% This function returns the Jacobian for voltage magnitudes (their 
%  derivatives) with respect to rectangular branch current variables.
%
% SYNTAX:
%   H = Jacobian_V_Irx(branch, Znod, bus, type, V)
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
%   Znod : matrix with size (num_nodes X num_branches) where, for each row
%           i, there is the list of branch impedances in the path between
%           first node of the grid and node i.
%   bus : nodes id where the real voltage measurements are taken.
%   type : type of estimator (2 if PMUs are present, 1 if no PMUs are
%           available)
%   V : structure with the vectors of the voltages in different formats
%        (mag, phase, real, imag, complex).
%
% OUTPUTS:
%   H : Jacobian matrix of voltage magnitudes for rectangular branch 
%        current state variables.

%% Jacobian calculation
nmeas = length(bus);                    % number voltage measurements
Hv = zeros(nmeas,type);                 % initialization derivatives with respect to both real and imaginary voltage
HIr = zeros(nmeas,branch.num);          % initialization submatrix derivatives wrt real currents
HIx = zeros(nmeas,branch.num);          % initialization submatrix derivatives wrt imaginary currents
for i = 1:nmeas
    m = bus(i);
    Hv(i,1) = cos(V.phase(m));          % derivative dV/dV (or dVr)
    if type == 2
        Hv(i,2) = sin(V.phase(m));      % derivative dV/dVx
    end
    HIr(i,:) = -real(Znod(m,:))*cos(V.phase(m)) - imag(Znod(m,:))*sin(V.phase(m));        % derivative dV/dIr
    HIx(i,:) = -real(Znod(m,:))*sin(V.phase(m)) + imag(Znod(m,:))*cos(V.phase(m));        % derivative dV/dIx
end
H = [Hv, HIr, HIx];                     % overall Jacobian