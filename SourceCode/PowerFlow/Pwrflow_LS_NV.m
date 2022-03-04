function [resPF, num_iter] = Pwrflow_LS_NV(branch, node, admittance) 
% This function returns the power flow (PF) results for the grid data given
%  in input (single phase equivalent model).
% The PF algorithm is based on a Least Squared approach and uses rectangular
%  voltages as state variables.
%
% SYNTAX:
%   [resPF, num_iter] = Pwrflow_LS_NV(branch, node, admittance)
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
%   node : structure with the following data about the grid nodes 
%       node.num = number of the nodes in the grid.
%       node.type = matrix of cells with the following information. 
%                  -------------- --------------- ---------------   
%                 | Type of node | 1st set point | 2nd set point |
%                 |--------------|---------------|---------------|  
%                 |   'slack'    |    V (p.u.)   |  theta (rad)  |
%                 |    'PQ'      |    P (p.u.)   |    Q (p.u.)   |
%                 |    'PV'      |    P (p.u.)   |    V (p.u.)   |
%
%   admittance : structure with the following admittance matrices  ->
%       Y : admittance matrix of the grid
%       Ys : matrix with only shunt admittances (out of the diagonal)
%
% OUTPUTS: 
%   resPF : nested structure with all the electrical data of the grid ->
%   resPF.V : structure with the vectors of the PF voltage results in different
%        formats (mag, phase, real, imag, complex).
%
%   resPF.I : structure with the vectors of the PF current results in different
%        formats (mag, phase, real, imag, complex) for:
%       I.br1 : branch current at the sending node.
%       I.br2 : branch current at the receiving node.
%       I.inj : nodal current injection.
%
%   resPF.S : structure with the vectors of the PF power results in different
%        formats (mag, phase, real, imag, complex) for:
%       S.br1 : power at the sending node.
%       S.br2 : power at the receiving node.
%       S.inj : power current injection.
%
%   num_iter : number of iterations for the PF algorithm to converge.

%% Initialization vectors & matrices
State = [ones(node.num,1); zeros(node.num,1)];      % state vector (real and imaginary voltages)
z = zeros(2*(node.num),1);                          % input/measurement vector
h = zeros(2*(node.num),1);                          % input/measurement functions
H = zeros(2*(node.num));                            % Jacobian
Y.complex = admittance.Y;                           % admittance matrix
Y = Complex_to_all(Y);
V.complex = ones(node.num,1);                       % Initialization voltage vector
V = Complex_to_all(V);                              % computation all voltages (mag, phase, real, imag)
epsilon = 5;                                        % convergence variable
num_iter = 0;                                       % iteration counter

%% Definition constant Jacobian and input/measurement vectors
for i = 1:node.num
    j = 2*(i-1)+1;
    type = node.type{i,1};                          % check type of node (slack, PQ or PV)
    switch type
        case 'slack'
            z(j) = node.type{i,2}*cos(node.type{i,3});      % conversion polar voltage in real voltage
            z(j+1) = node.type{i,2}*sin(node.type{i,3});    % conversion polar voltage in imaginary voltage
            H(j,:) = Jacobian_Vr_Vrx(node, i, 1);
            H(j+1,:) = Jacobian_Vx_Vrx(node, i, 1);
        case 'PQ'                                   % NB: pair of powers will be converted into equivalent rectangular currents
            H(j, :) = Jacobian_Iir_Vrx(node, Y, i, 1);                      
            H(j+1, :) = Jacobian_Iix_Vrx(node, Y, i, 1);
        case 'PV'
            z(j) = node.type{i,2};
            z(j+1) = node.type{i,3};
    end
end

%% Start iterative procedure
while epsilon > 10^-8                               % convergence threshold (could be changed to speed up the PF algorithm)
    if num_iter > 100                               % exit the while loop if the algorithm is not converging
        warning("The Power Flow reached the max number of iteration. Attention, the results may be inaccurate!")
        break
    end
    % Update non-costant Jacobian and input/measurement vectors
    for i = 1:node.num
        j = 2*(i-1)+1;
        type = node.type{i,1};
        switch type
            case 'slack'
                h(j) = H(j,:)*State;
                h(j+1) = H(j+1,:)*State;
            case 'PQ'
                [z(j), z(j+1)] = Pwr2curr(node.type{i,2}, node.type{i,3}, i, V);             % conversion PQ into rectangular currents
                h(j) = H(j,:)*State;
                h(j+1) = H(j+1,:)*State;
            case 'PV'
                h(j) = V.real(i)*(Y.real(i,:)*V.real-Y.imag(i,:)*V.imag) + V.imag(i)*(Y.real(i,:)*V.imag + Y.imag(i,:)*V.real);
                h(j+1) = V.mag(i);
                H(j, 1:node.num) = V.real(i).*Y.real(i,:) + V.imag(i).*Y.imag(i,:);
                H(j, i) = H(j,i) + Y.real(i,:)*V.real - Y.imag(i,:)*V.imag;
                H(j, node.num+1: end) = V.imag(i).*Y.real(i,:) - V.real(i).*Y.imag(i,:);
                H(j, i + node.num) = H(j,i+node.num) + Y.real(i,:)*V.imag + Y.imag(i,:)*V.real;
                H(j+1, :) = Jacobian_V_Vrx(node, i, 1, V);
        end
    end
    
    % Newton Raphson calculation                        
    r = z-h;                                        % input/measurement residual                                       
    Delta_State = H\r;                              % computation updating state vector
    State = State + Delta_State;                    % update of state vector
    epsilon = max(abs(Delta_State));                % check for convergence
    num_iter = num_iter + 1;                        % update iteration counter
    
    % Update calculated voltages
    V.real = State(1:node.num);
    V.imag = State(node.num+1:end);
    V.complex = complex(V.real,V.imag);
    V.mag = abs(V.complex);
    V.phase = angle(V.complex);
end

%% Computation of all the grid electrical quantities
resPF.V.complex = V.complex;
resPF.V.mag = V.mag;
resPF.V.phase = V.phase;
resPF.V.real = V.real;
resPF.V.imag = V.imag;

resPF.I = Calculation_currents(branch, resPF.V, admittance);
resPF.S = Calculation_powers(branch, resPF.V, resPF.I);