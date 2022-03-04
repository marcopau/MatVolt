function covSb = CovSb_from_CovIZrx(cov, branch, Znod, I, V, idx)
% This function computes the covariance matrix of branch currents in real
%  and imaginary coordinates starting from the covariance matrix of real
%  and imaginary voltages.
%
% SYNTAX:
%   covSb = CovSb_from_CovIZrx(cov, branch, Znod, I, V, idx)
%
% INPUTS:
%   cov : covariance matrix of the augmented branch current state vector 
%       (note that this also includes the voltages at a reference bus and
%       then the branch impedances in real and imaginary part)
%
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
%
%   I : structure with the vectors of the currents in different formats
%        (mag, phase, real, imag, complex).
%
%   V : structure with the vectors of the voltages in different formats
%        (mag, phase, real, imag, complex).
%
%   idx : index to differentiate powers at the sending (idx=1) or receiving
%          node (idx=2).
%
% OUTPUTS:
%   covVrx : covariance matrix of the voltages in rectangular coordinates.

%% Covariance matrix calculation for voltage and currents (uncertainty propagation)
nbus = size(Znod,1);
bus = (1:1:nbus)';
nbr = branch.num;
a = Jacobian_Vr_Irx(branch, Znod, bus, 2);      % derivative [dVr/dVr1, dVr/dVx1, dVr/dIr, dVr/dIx];
b = Jacobian_Vr_Zrx(Znod, bus, I);              % derivative [dVr/dR, dVr/dX];
c = Jacobian_Vx_Irx(branch, Znod, bus, 2);      % derivative [dVx/dVr1, dVx/dVx1, dVx/dIr, dVx/dIx];
d = Jacobian_Vx_Zrx(Znod, bus, I);              % derivative [dVx/dR, dVx/dX];
e = [zeros(2*nbr,2), eye(2*nbr), zeros(2*nbr)]; % derivative [dIrx/dVrx, dIrx/dIrx, dIrx/dRX];
der = [a, b; c, d; e];                          % overall derivative matrix
covVI = der * cov * der';                       % output covariance matrix of real and imaginary voltage and currents (uncertainty propagation law)

%% Covariance matrix calculation for powers (uncertainty propagation)
derP = zeros(branch.num, size(covVI,1));
derQ = zeros(branch.num, size(covVI,1));
for i=1:nbr
    if idx == 1
        n = branch.start(i);
    elseif idx == 2
        n = branch.end(i);
    end
    derP(i,n) = I.real(i);
    derP(i,n+nbus) = I.imag(i);
    derP(i,i+2*nbus) = V.real(n);
    derP(i,i+2*nbus+branch.num) = V.imag(n);
    derQ(i,n) = -I.imag(i);
    derQ(i,n+nbus) = I.real(i);
    derQ(i,i+2*nbus) = V.imag(i);
    derQ(i,i+2*nbus+branch.num) = -V.real(i);
end
derVI = [derP; derQ];
covSb = derVI * covVI * derVI';                 % output covariance matrix of active and reactive power (uncertainty propagation law)