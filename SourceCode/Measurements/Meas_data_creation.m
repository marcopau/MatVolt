function zdata = Meas_data_creation(branch, gridval, meas)
% This function returns the measurement data matrix with all the info
%  needed for the SE algorithms
%
% SYNTAX:
%   zdata = Meas_data_creation(branch, gridval, meas)
%
% INPUTS:
%   branch : structure with the following data about the grid branches
%       branch.num = number of branches in the grid
%       branch.start = vector with the numerical indexes of the nodes at  
%                      the sending end of each branch
%       branch.end = vector with the numerical indexes of the nodes at the 
%                    receiving end of each branch
%       branch.id = vector with the numerical indexes associated to each
%                    branch
%       branch.R : vector with the branch series resistances [in p.u.]
%       branch.X : vector with the branch series reactances [in p.u.]
%       branch.G : vector with branch shunt conductance [in p.u.]
%       branch.B : vector with the branch shunt susceptance [in p.u]  
%   
%   gridval : nested structure with all the electrical data of the grid ->
%       gridval.V : structure with the vectors of the bus voltages in 
%               different formats (mag, phase, real, imag, complex).
%
%       gridval.I : structure with the vectors of the currents in different 
%               formats (mag, phase, real, imag, complex) for:
%           I.br1 : branch current at the sending node.
%           I.br2 : branch current at the receiving node.
%           I.inj : nodal current injection.
%
%       gridval.S : structure with the vectors of the powers in different
%               formats (mag, phase, real, imag, complex) for:
%           S.br1 : power at the sending node.
%           S.br2 : power at the receiving node.
%           S.inj : power current injection.
%
%   meas : structure with the information of the location and uncertainties
%           of the measurements
%       meas.xxx.index : location (branch or node id) of the measurement "xxx"
%       meas.xxx.unc : uncertainty (in percent or in rad) of the measurement "xxx"
%           Types of measurements to be included in the 'meas' structure are:
%               V -> Voltage magnitude (traditional device)
%               Sinj -> Active & reactive power injection
%               S1 -> Active & reactive branch power (at the sending node)
%               S2 -> Active & reactive branch power (at the receiving node)
%               I1 -> Branch current magnitude (at the sending node)
%               I2 -> Branch current magnitude (at the receiving node)
%               V_pmu -> Voltage synchrophasor
%               Iinj_pmu -> Current injection synchrophasor
%               I1_pmu -> Branch current synchrophasor (at the sending node)
%               I2_pmu -> Branch current synchrophasor (at the receiving node)
%               Z -> Impedance branch measurements (for augmented SE
%                    formulations)
%           Missing measurements should be defined as an empty array.
%
% OUTPUTS:
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
%               21&22 -> real and imaginary branch impedances
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

%% Computation number of measurements for each category
numV = length(meas.V.index);                                               % number voltage magnitude meas
numPi = length(meas.Sinj.index);                                           % number active pwr inj meas
numQi = numPi;                                                             % number reactive pwr inj meas
numPf1 = length(meas.S1.index);                                            % number branch active pwr meas (sending node)
numPf2 = length(meas.S2.index);                                            % number branch active pwr meas (receiving node)
numQf1 = numPf1;                                                           % number branch reactive pwr meas (sending node)
numQf2 = numPf2;                                                           % number branch reactive pwr meas (receiving node)
numI1 = length(meas.I1.index);                                             % number branch current magnitude meas (sending node)
numI2 = length(meas.I2.index);                                             % number branch current magnitude meas (receiving node)
numVpmu = length(meas.V_pmu.index);                                        % number PMU voltage meas
numIipmu = length(meas.Iinj_pmu.index);                                    % number PMU current injection meas
numI1pmu = length(meas.I1_pmu.index);                                      % number PMU branch current meas (sending node)
numI2pmu = length(meas.I2_pmu.index);                                      % number PMU branch current meas (receiving node)
if ~isfield(meas, 'Z')                                                     
    meas.Z.index = [];
    meas.Z.unc = [];
end
numR = length(meas.Z.index);                                               % number real impedance values
numX = length(meas.Z.index);                                               % number imaginary impedance values

num_meas = numV + 2*numPi +2*numPf1 + 2*numPf2 + numI1 + numI2 + ...
    2*numVpmu + 2*numIipmu + 2*numI1pmu + 2*numI2pmu + numR + numX;        % total number of measurements

%% Definition codes associated to each type of measurement
t1 = ones(numV,1);                                                         % code = 1 -> voltage magnitude meas
t2 = 2*ones(numPi,1);                                                      % code = 2 -> active pwr inj meas
t3 = 3*ones(numQi,1);                                                      % code = 3 -> reactive pwr inj meas
t4 = 4*ones(numPf1+numPf2,1);                                              % code = 4 -> active branch pwr meas
t5 = 5*ones(numQf1+numQf2,1);                                              % code = 5 -> reactive branch pwr meas
t6 = 6*ones(numI1+numI2,1);                                                % code = 6 -> branch current magnitude meas
t7 = 7*ones(numVpmu,1);                                                    % code = 7 -> PMU voltage magnitude meas
t8 = 8*ones(numVpmu,1);                                                    % code = 8 -> PMU voltage phase angle meas
t9 = 9*ones(numIipmu,1);                                                   % code = 9 -> PMU current injection magnitude meas
t10 = 10*ones(numIipmu,1);                                                 % code = 10 -> PMU current injection phase angle meas
t11 = 11*ones(numI1pmu+numI2pmu,1);                                        % code = 11 -> PMU branch current magnitude meas
t12 = 12*ones(numI1pmu+numI2pmu,1);                                        % code = 12 -> PMU branch current phase angle meas
t21 = 21*ones(numR,1);                                                     % code = 21 -> real branch impedance values
t22 = 22*ones(numX,1);                                                     % code = 22 -> imaginary branch impedance values

type = [t1; t2; t3; t4; t5; t6; t7; t8; t9; t10; t11; t12; t21; t22];      %%% 1st column of zdata matrix

%% Definition of the true values at the measurement points
z1 = gridval.V.mag(meas.V.index);                                          % voltage magnitude at the measurement points
z2 = gridval.S.inj.real(meas.Sinj.index);                                  % active power inj at the measurement points
z3 = gridval.S.inj.imag(meas.Sinj.index);                                  % reactive power inj at the measurement points
z4 = gridval.S.br1.real(meas.S1.index);                                    % active branch power at the measurement points (sending node)
z4b = gridval.S.br2.real(meas.S2.index);                                   % reactive branch power at the measurement points (receiving node)
z5 = gridval.S.br1.imag(meas.S1.index);                                    % active branch power at the measurement points (sending node)
z5b = gridval.S.br2.imag(meas.S2.index);                                   % reactive branch power at the measurement points (receiving node)
z6 = gridval.I.br1.mag(meas.I1.index);                                     % branch current magnitude at the measurement points (sending node)
z6b = gridval.I.br2.mag(meas.I2.index);                                    % branch current magnitude at the measurement points (receiving node)
z7 = gridval.V.mag(meas.V_pmu.index);                                      % voltage magnitude at the PMU meas points
z8 = gridval.V.phase(meas.V_pmu.index);                                    % voltage phase angle at the PMU meas points
z9 = gridval.I.inj.mag(meas.Iinj_pmu.index);                               % current inj magnitude at the PMU meas points
z10 = gridval.I.inj.phase(meas.Iinj_pmu.index);                            % current inj phase angle at the PMU meas points
z11 = gridval.I.br1.mag(meas.I1_pmu.index);                                % branch current magntude at the PMU meas points (sending node)
z11b = gridval.I.br2.mag(meas.I2_pmu.index);                               % branch current magnitude at the PMU meas points (receiving node)
z12 = gridval.I.br1.phase(meas.I1_pmu.index);                              % branch current phase angle at the PMU meas points (sending node)
z12b = gridval.I.br2.phase(meas.I2_pmu.index);                             % branch current phase angle at the PMU meas points (receiving node)
z21 = branch.R(meas.Z.index);                                              % real branch impedance values
z22 = branch.X(meas.Z.index);                                              % imaginary branch impedance values

z = [z1; z2; z3; z4; z4b; z5; z5b; z6; z6b; z7; ...
    z8; z9; z10; z11; z11b; z12; z12b; z21; z22];                          %%% 2nd columm zdata matrix

%% Definition associated nodes/branches for each measurement
V_id = meas.V.index;
Sinj_id = meas.Sinj.index;          
S1_id = branch.id(meas.S1.index);
S2_id = - branch.id(meas.S2.index);                                        % NB: sign minus to discern that the meas is at the receiving node
I1_id = branch.id(meas.I1.index);
I2_id = - branch.id(meas.I2.index);                                        % NB: sign minus to discern that the meas is at the receiving node
Vmag_pmu_id = meas.V_pmu.index;
Vph_pmu_id = meas.V_pmu.index;
Iimag_pmu_id = meas.Iinj_pmu.index;
Iiph_pmu_id = meas.Iinj_pmu.index;
I1mag_pmu_id = branch.id(meas.I1_pmu.index);
I1ph_pmu_id = branch.id(meas.I1_pmu.index);
I2mag_pmu_id = - branch.id(meas.I2_pmu.index);                             % NB: sign minus to discern that the meas is at the receiving node
I2ph_pmu_id = - branch.id(meas.I2_pmu.index);                              % NB: sign minus to discern that the meas is at the receiving node
R_id = branch.id(meas.Z.index);
X_id = branch.id(meas.Z.index);

id = [V_id; Sinj_id; Sinj_id; S1_id; S2_id; S1_id; S2_id;  
    I1_id; I2_id; Vmag_pmu_id; Vph_pmu_id; Iimag_pmu_id; Iiph_pmu_id; 
    I1mag_pmu_id; I2mag_pmu_id; I1ph_pmu_id; I2ph_pmu_id; R_id; X_id];     %%% 3rd column zdata matrix

%% definition standard deviation for the different types of measurements
V_std_dev = Calculation_std_dev(meas.V.unc, 'percent', z1);
Pinj_std_dev = Calculation_std_dev(meas.Sinj.unc, 'percent', z2);
Qinj_std_dev = Calculation_std_dev(meas.Sinj.unc, 'percent', z3);
P1_std_dev = Calculation_std_dev(meas.S1.unc, 'percent', z4);
P2_std_dev = Calculation_std_dev(meas.S2.unc, 'percent', z4b);
Q1_std_dev = Calculation_std_dev(meas.S1.unc, 'percent', z5);
Q2_std_dev = Calculation_std_dev(meas.S2.unc, 'percent', z5b);
I1_std_dev = Calculation_std_dev(meas.I1.unc, 'percent', z6);
I2_std_dev = Calculation_std_dev(meas.I2.unc, 'percent', z6b);
Vmag_pmu_std_dev = Calculation_std_dev(meas.V_pmu.unc(1), 'percent', z7);
Vph_pmu_std_dev = Calculation_std_dev(meas.V_pmu.unc(2), 'absolute', z8);
Iimag_pmu_std_dev = Calculation_std_dev(meas.Iinj_pmu.unc(1), 'percent', z9);
Iiph_pmu_std_dev = Calculation_std_dev(meas.Iinj_pmu.unc(2), 'absolute', z10);
I1mag_pmu_std_dev = Calculation_std_dev(meas.I1_pmu.unc(1), 'percent', z11);
I1ph_pmu_std_dev = Calculation_std_dev(meas.I1_pmu.unc(2), 'absolute', z12);
I2mag_pmu_std_dev = Calculation_std_dev(meas.I2_pmu.unc(1), 'percent', z11b);
I2ph_pmu_std_dev = Calculation_std_dev(meas.I2_pmu.unc(2), 'absolute', z12b);
R_std_dev = Calculation_std_dev(meas.Z.unc, 'percent', z21);
X_std_dev = Calculation_std_dev(meas.Z.unc, 'percent', z22);

std_dev = [V_std_dev; Pinj_std_dev; Qinj_std_dev; P1_std_dev; P2_std_dev; 
    Q1_std_dev; Q2_std_dev; I1_std_dev; I2_std_dev; Vmag_pmu_std_dev; Vph_pmu_std_dev; 
    Iimag_pmu_std_dev; Iiph_pmu_std_dev; I1mag_pmu_std_dev; 
    I2mag_pmu_std_dev; I1ph_pmu_std_dev; I2ph_pmu_std_dev; R_std_dev; X_std_dev];            %%% 4th column zdata matrix

%% Definition overall zdata matrix
zdata = zeros(num_meas,4);
zdata(:,1) = type;
zdata(:,2) = z;
zdata(:,3) = id;
zdata(:,4) = std_dev;