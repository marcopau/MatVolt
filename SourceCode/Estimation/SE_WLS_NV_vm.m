function [resSE, num_iter, unc] = SE_WLS_NV_vm(branch, node, zdata, admittance)
% This function returns the State Estimation (SE) results for the grid data
%  given in input (single phase equivalent model).
% The SE algorithm is based on a Weighted Least Squared approach and uses
%  rectangular voltages as state variables + virtual measurements for zero
%  injections and other equality constraints..
%
% SYNTAX:
%   [resSE, num_iter] = SE_WLS_NV_vm(branch, node, zdata, admittance)
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
%   zdata : matrix of the measurement info to be given in input to a SE 
%            algorithm, with the following structure (see Table columns below). 
%                  --------- ------- -------- -------   
%                 | Type of | Meas  | Meas |  Meas   |
%                 |   meas  | value |  id  | std dev |
%                  --------- ------- -------- -------   
%
%           1) Type of meas : id code associated to each type of measurement.
%                           The used ID codes are:
%                   1 -> voltage magnitude
%                 2&3 -> active & reactive pwr injection
%                 4&5 -> active & reactive branch pwr
%                   6 -> current magnitude
%                 7&8 -> PMU voltage phasor (magnitude & phase angle)
%                9&10 -> PMU current inj phasor (magnitude & phase angle)
%               11&12 -> PMU branch current phasor (magnitude & phase angle)
%
%           2) Meas value : numerical value of the measurements
%           
%           3) Meas id : id of the branch or node where the measurement is
%                 taken. Negative values for branch measurements indicate 
%                 that the measurement is taken at the receiving node (thus 
%                 in a direction opposite to the convention used to define 
%                 start node and end node of the branch).
%                 
%           4) Meas std dev : standard deviation associated to the
%                 measurements due to their uncertainty.
%
%   admittance : structure with the following admittance matrices  ->
%       Y : admittance matrix of the grid
%       Ys : matrix with only shunt admittances (out of the diagonal)
%
% OUTPUTS: 
%   resSE : nested structure with all the electrical data of the grid ->
%   resSE.V : structure with the vectors of the SE voltage results in different
%        formats (mag, phase, real, imag, complex).
%
%   resSE.I : structure with the vectors of the SE current results in different
%        formats (mag, phase, real, imag, complex) for:
%       I.br1 : branch current at the sending node.
%       I.br2 : branch current at the receiving node.
%       I.inj : nodal current injection.
%
%   resSE.S : structure with the vectors of the SE power results in different
%        formats (mag, phase, real, imag, complex) for:
%       S.br1 : power at the sending node.
%       S.br2 : power at the receiving node.
%       S.inj : power current injection.
%
%   num_iter : number of iterations for the SE algorithm to converge.
%
%   unc : nested structure with all the theoretical uncertainties of the
%        estimation results
%   unc.V : structure with the vectors of the voltage uncertainties in 
%        different formats (mag, phase, real, imag).
%
%   unc.I : structure with the vectors of the current uncertainties in 
%        different formats (mag, phase, real, imag) for:
%       I.br : branch current.
%       I.inj : nodal current injection.
%
%   unc.S : structure with the vectors of the power uncertainties in 
%        different formats (real, imag) for:
%       S.br1 : power at the sending node.
%       S.br2 : power at the receiving node.
%       S.inj : power current injection.

%% Loop for bad data control
bdata_id = 1;
while bdata_id == 1
    %% Extraction values from input zdata matrix
    ztype = zdata(:,1);                                                    % id measurement types
    rx = ztype>20;                                                         % check for possible presence of impedances as measurements
    if sum(rx)>0
        warning('impedances will be considered as fixed values; to consider them as variables, use an augmented state estimation formulation.')
    end
    zdata(rx,:) = [];                                                      % remove possible measurements associated to branch impedances
    z = zdata(:,2);                                                        % measurement vector
    zid = zdata(:,3);                                                      % id branch or node of the measurements
    zstd = zdata(:,4);                                                     % standard deviation of measurements
    zvar = zstd.^2;                                                        % variance of measurements
    zidx = zvar<10^-11;                                                    % list of virtual measurements or other measurements with too low standard deviation
    zvar(zidx) = 10^-11;                                                   % threshold for the lowest variance used to avoid matrix ill-conditioning

    %% Identification different measurement types
    vi = (ztype == 1);                                                     % index of voltage magnitude measurements
    pii = (ztype == 2);                                                    % index of active power injection measurements
    qii = (ztype == 3);                                                    % index of reactive power injection measurements
    pfi = (ztype == 4);                                                    % index of active branch power measurements
    qfi = (ztype == 5);                                                    % index of reactive branch power measurements
    ifi = (ztype == 6);                                                    % index of branch current magnitude measurements
    syncvmi = (ztype == 7);                                                % index of PMU voltage magnitude measurements
    syncvpi = (ztype == 8);                                                % index of PMU voltage angle measurements
    synciimi = (ztype == 9);                                               % index of PMU current injection magnitude measurements
    synciipi = (ztype == 10);                                              % index of PMU current injection angle measurements
    syncifmi = (ztype == 11);                                              % index of PMU branch current magnitude measurements
    syncifpi = (ztype == 12);                                              % index of PMU branch current angle measurements

    %% Identification nodes/branches associated to measurements
    busv = zid(vi);                                                        % id nodes of voltage magnitude measurements
    buspi = zid(pii);                                                      % id nodes of power injection measurements
    brpf = zid(pfi);                                                       % id branches of branch power measurements
    [buspf, ~] = Bus_of_branch(branch, brpf);                              % id nodes of branch power measurements
    brif = zid(ifi);                                                       % id branches of branch current magnitude measurements
    bussyncv = zid(syncvmi);                                               % id nodes of PMU voltage measurements 
    bussyncii = zid(synciimi);                                             % id nodes of PMU current injection measurements 
    brsyncif = zid(syncifmi);                                              % id branches of PMU branch current measurements 

    %% Initialization vectors and variables for SE
    V = Flat_start_voltage(node.num);
    Y.complex = admittance.Y;                                              % grid admittance matrix
    Y = Complex_to_all(Y);
    if ~isempty(bussyncv)                                                  % detect if there are PMU measurements in input
        SEtype = 1;                                                        % estimator with PMUs
    else 
        SEtype = 2;                                                        % estimator without PMUs
    end
    State = [V.real; V.imag(SEtype:end)];                                  % definition state vector for WLS
    num_iter = 0;                                                          % initialization WLS iterations counter
    epsilon = 5;                                                           % initialization variable for convergence check
    thresh = 10^-8;                                                        % threshold for SE algorithm convergence

    %% Definition constant weighting sub-matrices
    W1 = diag(1./zvar(vi));                                                                     % Weights voltage magnitudes
    W78 = Weight_PMU_rect(z(syncvmi,1),z(syncvpi,1),zvar(syncvmi,1),zvar(syncvpi,1));           % Weights PMU voltages
    W910 = Weight_PMU_rect(z(synciimi,1),z(synciipi,1),zvar(synciimi,1),zvar(synciipi,1));      % Weights PMU current inj
    W1112 = Weight_PMU_rect(z(syncifmi,1),z(syncifpi,1),zvar(syncifmi,1),zvar(syncifpi,1));     % Weights PMU branch currents

    %% Update measurement vector with conversion of PMU meas in rect coordinates
    [z(syncvmi),z(syncvpi)] = pol2cart(z(syncvpi),z(syncvmi));             % conversion PMU voltage measurements
    [z(synciimi),z(synciipi)] = pol2cart(z(synciipi),z(synciimi));         % conversion PMU current inj measurements
    [z(syncifmi),z(syncifpi)] = pol2cart(z(syncifpi),z(syncifmi));         % conversion PMU branch current measurements

    %% Definition constant Jacobian sub-matrices
    H2 = Jacobian_Iir_Vrx(node, Y, buspi, SEtype);                         % Jacobian active pwr injections
    H3 = Jacobian_Iix_Vrx(node, Y, buspi, SEtype);                         % Jacobian reactive pwr injections
    H4 = Jacobian_Ifr_Vrx(node, branch, admittance, brpf, SEtype);         % Jacobian active branch powers
    H5 = Jacobian_Ifx_Vrx(node, branch, admittance, brpf, SEtype);         % Jacobian reactive branch powers
    H7 = Jacobian_Vr_Vrx(node, bussyncv, SEtype);                          % Jacobian PMU real voltages
    H8 = Jacobian_Vx_Vrx(node, bussyncv, SEtype);                          % Jacobian PMU imaginary voltages
    H9 = Jacobian_Iir_Vrx(node, Y, bussyncii, SEtype);                     % Jacobian PMU real current injections
    H10 = Jacobian_Iix_Vrx(node, Y, bussyncii, SEtype);                    % Jacobian PMU imaginary current injections
    H11 = Jacobian_Ifr_Vrx(node, branch, admittance, brsyncif, SEtype);    % Jacobian PMU real branch currents
    H12 = Jacobian_Ifx_Vrx(node, branch, admittance, brsyncif, SEtype);    % Jacobian PMU imaginary branch currents

    %% Iterative part of the WLS
    while epsilon > thresh
        if num_iter > 100                                                  % exit the while loop if the algorithm is not converging
            warning("The SE algorithm reached the max number of iteration. Attention, the results may be inaccurate!")
            break
        end
        %%% Computation equivalent current measurements for pwr inj and branch pwr;
        [z(pii,1),z(qii,1)] = Pwr2curr(zdata(pii,2),zdata(qii,2),buspi,V);     % power injections conversion
        [z(pfi,1),z(qfi,1)] = Pwr2curr(zdata(pfi,2),zdata(qfi,2),buspf,V);     % branch power conversion

        %%% Computation measurement functions h(x)
        h1 = V.mag(busv);                                                  % meas function h(x) for voltage magnitude meas
        h2 = H2*State;      h3 = H3*State;                                 % meas function h(x) for power inj meas 
        h4 = H4*State;      h5 = H5*State;                                 % meas function h(x) for branch power meas
        h6 = MeasFunc_I_Vrx(branch, Y, brif, V);                           % meas function h(x) for current magnitude meas
        h7 = H7*State;      h8 = H8*State;                                 % meas function h(x) for PMU voltage meas
        h9 = H9*State;      h10 = H10*State;                               % meas function h(x) for PMU current inj meas
        h11 = H11*State;    h12 = H12*State;                               % meas function h(x) for PMU branch current meas

        %%% Computation non-constant Jacobian sub-matrices
        H1 = Jacobian_V_Vrx(node, busv, SEtype, V);                        % Jacobian voltage magnitudes
        H6 = Jacobian_I_Vrx(node, branch, Y, brif, SEtype, V);             % Jacobian current magnitudes

        %%% Computation non-constant weighting sub-matrices
        W23 = Weight_pwr2curr(V,buspi,zvar(pii,1),zvar(qii,1));            % Weights power injections
        W45 = Weight_pwr2curr(V,buspf,zvar(pfi,1),zvar(qfi,1));            % Weights branch powers

        %%% If they exist, remove current magnitude measurements at the first iteration
        if num_iter == 0
            h6 = [];  H6 = [];  W6 = [];  z(ifi,:) = [];                   % removal current magnitude data
        elseif num_iter == 1 && ~isempty(brif)                             % re-introduction current magnitude data
            W6 = diag(1./zvar(ifi));                
            idx = find(ifi,1);
            z = [z(1:idx-1); zdata(ifi,2); z(idx:end)];
        end

        %%% Creation matrices and vectors for WLS
        H = [H1; H2; H3; H4; H5; H6; H7; H8; H9; H10; H11; H12];           % creation overall Jacobian matrix
        h = [h1; h2; h3; h4; h5; h6; h7; h8; h9; h10; h11; h12];           % creation overall meas function h(x)
        W = blkdiag(W1, W23, W45, W6, W78, W910, W1112);                   % creation overall weighting matrix

        %%% WLS computation
        [dX, epsilon, r] = WLS_calc(z, h, H, W);                           % WLS computation                      
        State = State + dX;                                                % state variables update
        num_iter = num_iter + 1;                                           % update iteration counter

        %%% Update voltage vector
        V.real = State(1:node.num);
        V.imag(SEtype:end) = State(node.num+1:end);
        V.complex = complex(V.real,V.imag);
        V.mag = abs(V.complex);
        V.phase = angle(V.complex);  
    end
    
    %% Check for bad data
    bdata_idx = Bad_data_LNR(H, W, r, zidx);
    if ~isempty(bdata_idx)
        zdata = Bad_data_remove(zdata, bdata_idx);  
    else
        bdata_id = 0;
    end
end

%% Computation of all the grid electrical quantities
resSE.V.complex = V.complex;
resSE.V.mag = V.mag;
resSE.V.phase = V.phase;
resSE.V.real = V.real;
resSE.V.imag = V.imag;
resSE.I = Calculation_currents(branch, resSE.V, admittance);
resSE.S = Calculation_powers(branch, resSE.V, resSE.I);

%% Computation theoretical covariance matrices (optional)
covV.rx = inv(H'*W*H);                                                         % covariance matrix rectangular voltages
if SEtype == 2
   covV.rx = [covV.rx(1:node.num,:); zeros(1,2*node.num-1); covV.rx(node.num+1:end,:)];
   covV.rx = [covV.rx(:,1:node.num), zeros(2*node.num,1), covV.rx(:,node.num+1:end)];
end
covV.mp = CovXmp_from_CovXrx(covV.rx, resSE.V);                                % covariance matrix polar voltages
covIb.rx = CovIbrx_from_CovVrx(covV.rx, node, branch, admittance);             % covariance matrix rectangular branch currents
covIb.mp = CovXmp_from_CovXrx(covIb.rx, resSE.I.br1);                          % covariance matrix polar branch currents
covIi.rx = CovIirx_from_CovIbrx(covIb.rx, node, branch);                       % covariance matrix rectangular current injections
covIi.mp = CovXmp_from_CovXrx(covIi.rx, resSE.I.inj);                          % covariance matrix polar branch currents
covSb1.rx = CovSb_from_CovVrx(covV.rx, resSE.V, node, branch, admittance, 1);  % covariance matrix branch powers (at the sending node)
covSb1.mp = CovXmp_from_CovXrx(covSb1.rx, resSE.S.br1);                        % covariance matrix polar branch currents
covSb2.rx = CovSb_from_CovVrx(covV.rx, resSE.V, node, branch, admittance, 2);  % covariance matrix branch powers (at the receiving node)
covSb2.mp = CovXmp_from_CovXrx(covSb2.rx, resSE.S.br2);                        % covariance matrix polar branch currents
covSinj.rx = CovIirx_from_CovIbrx(covSb1.rx, node, branch);                    % covariance matrix power injections (NB: approximated calculation)
covSinj.mp = CovXmp_from_CovXrx(covSinj.rx, resSE.S.inj);                      % covariance matrix polar branch currents

%% Computation estimation uncertainties (optional)
unc.V = Unc_from_cov_call(covV, resSE.V);                                   % structure with voltage estimation uncertainties
unc.I.br1 = Unc_from_cov_call(covIb, resSE.I.br1);                          % structure with branch current estimation uncertainties (sending node)
unc.I.br2 = Unc_from_cov_call(covIb, resSE.I.br2);                          % structure with branch current estimation uncertainties (receiving node)
unc.I.inj = Unc_from_cov_call(covIi, resSE.I.inj);                          % structure with current injection estimation uncertainties
unc.S.br1 = Unc_from_cov_call(covSb1, resSE.S.br1);                         % structure with branch power estimation uncertainties (sending node)
unc.S.br2 = Unc_from_cov_call(covSb2, resSE.S.br2);                         % structure with branch power estimation uncertainties (receiving node)
unc.S.inj = Unc_from_cov_call(covSinj, resSE.S.inj);                        % structure with power injection estimation uncertainties