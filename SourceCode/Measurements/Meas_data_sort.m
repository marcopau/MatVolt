function zdata = Meas_data_sort(zdata)
% This function returns the measurement data matrix with the rows sorted
% according to their measurement id and the measurement pairs (powers,
% phasors) placed with the same order
%
% SYNTAX:
%   zdata = Meas_data_sort(zdata)
%
% INPUT & OUTPUT:
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

%% Sorting zdata matrix per measurement type
[~, idx] = sort(zdata(:,1));
zdata = zdata(idx,:);

%% Sorting measurement in pairs per branch/node id
meas_id = [2,3,4,5,7,8,9,10,11,12,21,22];         % types id of measurements usually expressed in pairs (powers, phasors, impedances)
for i = 1:length(meas_id)
    type = meas_id(i);
    rows = zdata(:,1) == type;
    zdata2 = zdata(rows,:);                 % submatrix of measurement data of the considered type
    [~, idx] = sort(zdata2(:,3));           % sort the measurement data by their branch/node id
    zdata2 = zdata2(idx,:);
    zdata(rows,:) = zdata2;                 % replace the sorted submatrix in the overall measurement matrix
end