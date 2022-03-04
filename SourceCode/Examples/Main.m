clc
clear
close all

addpath(genpath('..\'))
s = RandStream.create('mt19937ar','seed',152489);                          % random extraction starting from the specified seed
RandStream.setGlobalStream(s);

%% Definition of the network data;
Srated = 10e6;                                                             % base power for conversion in per unit
Vrated = 11e3;                                                             % base voltage for conversion in per unit
base = Base_value_calc(Srated, Vrated);                                    % computation of all the other base values 
[branch, node] = Network_95_nodes_data(base);                              % function with the network data
[admittance] = Ymatrix(branch, node);                                      % computation admittance matrix of the network

%% Calculation via power flow of the state assumed as reference operating condition of the network;
[resPF_pu, num_iter] = Pwrflow_LS_NV(branch, node, admittance);

%% Post-processing power flow results
%%% Conversion from per unit to actual values
[resPF] = Conversion_from_pu_call(resPF_pu, base);
%%% Rounding of very small values to zero
[resPF_pu] = Round_grid_val_call(resPF_pu);
%%% Optional saving and displaying of the PF results
% Values_grid_save(branch, node, resPF, '.xlsx');
% Values_node_print(node, resPF_pu);
% Values_branch_print(branch, resPF);

%% Definition measurement placement;
%%% Placement of traditional measurements
meas.V.index = [1]';                                                       % nodes where voltage magnitude meas are placed
meas.Sinj.index = [2:1:node.num]';                                         % nodes for the power injection meas
meas.S1.index = []';                                                       % branches where active and reactive power meas are placed (meas on the sending node)
meas.S2.index = []';                                                       % branches where active and reactive power meas are placed (meas on the receiving node)
meas.I1.index = []';                                                       % branches where current magnitude meas are placed (meas on the sending node)
meas.I2.index = []';                                                       % branches where current magnitude meas are placed (meas on the receiving node)

%%% Placement of PMU measurements
meas.V_pmu.index = []';                                                    % nodes where PMU voltage meas are placed
meas.Iinj_pmu.index = []';                                                 % nodes where PMU current inj meas are placed
meas.I1_pmu.index = []';                                                   % branches where PMU branch current meas are placed (sending node)
meas.I2_pmu.index = []';                                                   % branches where PMU branch current meas are placed (receiving node)

%%% Impedance measurements (for augmented SE, comment it otherwise)
meas.Z.index = (1:1:branch.num)';                                          % for augmented SE, if impedances are considered as measurements

%% Definition measurement uncertainties;
%%% Traditional measurements
meas.V.unc = 1;                                                            % uncertainty (in percent) of voltage magnitude measurements 
meas.Sinj.unc = 10;                                                        % uncertainty (in percent) of active and reactive power injection measurements (or pseudo-measurements) 
meas.S1.unc = 1;                                                           % uncertainty (in percent) of active and reactive branch power measurements
meas.S2.unc = 1;                                                           % uncertainty (in percent) of active and reactive branch power measurements
meas.I1.unc = 1;                                                           % uncertainty (in percent) of current magnitude measurements
meas.I2.unc = 1;                                                           % uncertainty (in percent) of current magnitude measurements

%%% PMU measurements (pair of uncertainty values - for magnitude and phase angles)
meas.V_pmu.unc = [0.0, 0.0];                                               % uncertainty of magnitude (in percent) and phase angle (in rad) for voltage PMU measurements
meas.Iinj_pmu.unc = [0.0, 0.0];                                            % uncertainty of magnitude (in percent) and phase angle (in rad) for current inj PMU measurements
meas.I1_pmu.unc = [0.0, 0.0];                                              % uncertainty of magnitude (in percent) and phase angle (in rad) for branch current PMU measurements
meas.I2_pmu.unc = [0.0, 0.0];                                              % uncertainty of magnitude (in percent) and phase angle (in rad) for branch current PMU measurements

%%% Impedance measurements (for augmented SE, comment it otherwise)
meas.Z.unc = 0;                                                           % uncertainty (in percent) of the impedances (for augmented SE)

%% Creation of the matrix containing the measurement data/information in input to SE;
[zdatatrue] = Meas_data_creation(branch, resPF_pu, meas);
[zdatatrue] = Meas_data_sort(zdatatrue);
[zdatatrue] = Meas_data_filter(zdatatrue);

%% Initialization variables for Monte Carlo simulation
MC_trials = 1;                                                             % number of Monte Carlo trials
V_est_matrix = zeros(node.num, MC_trials);                                 % initialization vectors that will contain the node voltage estimation results
I_est_matrix = zeros(branch.num, MC_trials);                               % initialization vectors that will contain the branch current estimation results
SE_iter_num = zeros(1, MC_trials);                                         % initialization vecctor that will contain the number of iteration needed for the SE algorithm convergence

%% Monte Carlo simulation
for mciter=1:MC_trials                                                     % start of the Monte Carlo iterations                  
if mod(mciter, 100)==0                                                     % mciter value in output to verify that the algorithm is properly running
    mciter
end

%%% Generation random measurement data values
[zdata] = Meas_noise_generation(zdatatrue);                                % random generation of the measurements, starting from the true values, according to the distribution uncertainty of each measurement
% types_to_keep = [2, 3, 7, 8, 9, 10, 11, 12]';
% [zdata_PMU] = Meas_data_reduction(zdata, types_to_keep);                   % creation of subset of measurements, with only the meas indicated in meas_types

%%% Execution SE algorithm
[resSE_pu, num_iter, unc] = SE_WLS_NV_vm(branch, node, zdata, admittance);
[resSE2_pu, num_iter2, unc2] = SE_WLS_BC_augmented(branch, node, zdata, admittance);

%%% Save SE results
V_est_matrix(:,mciter) = resSE_pu.V.complex;
I_est_matrix(:,mciter) = resSE_pu.I.br1.complex;
SE_iter_num(mciter) = num_iter;

end

%% Calculation statistical results from Monte Carlo simulation
%%% calculation of the standard deviation of the errors (for I_abs, I_theta, V_abs, V_theta)
%%% NB: for the estimators using PMUs the phase angle difference with respect to the slack bus is also considered in order to have comparable results with respect to conventional estimators without PMUs

stdI_abs = std(abs(I_est_matrix) - resPF_pu.I.br1.mag*ones(1,MC_trials),0,2);
stdI_phase = std(angle(exp(1i.*(angle(I_est_matrix) - resPF_pu.I.br1.phase*ones(1,MC_trials)))),0,2);
stdV_abs = std(abs(V_est_matrix) - resPF_pu.V.mag*ones(1,MC_trials),0,2);
stdV_phase = std(angle(exp(1i.*(angle(V_est_matrix) - resPF_pu.V.phase*ones(1,MC_trials)))),0,2);

figure(1);                                                                                                  % plot current magnitude estimation results
subplot(3,1,1)                                                                                              % subplot std dev results
plot(300*stdI_abs./resPF_pu.I.br1.mag,'b');
subplot(3,1,2)                                                                                              % subplot RMSE results
plot(300*sqrt(mean((abs(I_est_matrix) - resPF_pu.I.br1.mag*ones(1,MC_trials)).^2,2))./resPF_pu.I.br1.mag,'b');
subplot(3,1,3)                                                                                              % subplot mean error results
plot(100*mean((abs(I_est_matrix) - resPF_pu.I.br1.mag*ones(1,MC_trials)),2)./resPF_pu.I.br1.mag,'b');

figure(2);                                                                                                  % plot current phase angle estimation results
subplot(3,1,1)                                                                                              % subplot std dev results
plot(3*stdI_phase,'b');
subplot(3,1,2)                                                                                              % subplot RMSE reuslts
plot(3*sqrt(mean((angle(exp(1i.*(angle(I_est_matrix) - resPF_pu.I.br1.phase*ones(1,MC_trials))))).^2,2)),'b');
subplot(3,1,3)                                                                                              % subplot mean error results
plot(mean((angle(exp(1i.*(angle(I_est_matrix) - resPF_pu.I.br1.phase*ones(1,MC_trials))))),2),'b');

figure(3);                                                                                                  % plot voltage magnitude estimation results
subplot(3,1,1)                                                                                              % subplot std dev results
plot(300*stdV_abs./resPF_pu.V.mag,'b');
subplot(3,1,2)                                                                                              % subplot RMSE results
plot(300*sqrt(mean((abs(V_est_matrix) - resPF_pu.V.mag*ones(1,MC_trials)).^2,2))./resPF_pu.V.mag,'b');
subplot(3,1,3)                                                                                              % subplot mean error results
plot(100*mean((abs(V_est_matrix) - resPF_pu.V.mag*ones(1,MC_trials)),2)./resPF_pu.V.mag,'b');

figure(4);                                                                                                  % plot voltage phase angle estimation results
subplot(3,1,1)                                                                                              % subplot std dev resutls
plot(3*stdV_phase,'b');
subplot(3,1,2)                                                                                              % subplot RMSE results
plot(3*sqrt(mean((angle(exp(1i.*(angle(V_est_matrix) - resPF_pu.V.phase*ones(1,MC_trials))))).^2,2)),'b');
subplot(3,1,3)                                                                                              % subplot mean error results
plot(mean((angle(exp(1i.*(angle(V_est_matrix) - resPF_pu.V.phase*ones(1,MC_trials))))),2),'b');

