function zdata = Meas_data_filter(zdata)
% This function checks if both measurements are available for the 
% measurement pairs (powers, phasors); if not, single measurements of a
% measurement pair will be removed.
%
% SYNTAX:
%   zdata = Meas_filter_sort(zdata)
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

%% Check measurement pairs
meas_id = [2,4,7,9,11,21];                                      % id types of measurements usually expressed in pairs (powers, phasors, impedances)
for i = 1:length(meas_id)
    type1 = meas_id(i);
    type2 = type1+1;                                            % id type of the associated measurement in the pair
    idx1 = zdata(:,1) == type1;
    idx2 = zdata(:,1) == type2;
    id_meas1 = zdata(idx1,3);                                   % branch/node id of the available measurements for the first type 
    id_meas2 = zdata(idx2,3);                                   % branch/node id of the available measurements for the second type 
    diff1 = setdiff(id_meas1, id_meas2);                        % check for ids in id_meas1 that are not present in id_meas2
    diff2 = setdiff(id_meas2, id_meas1);                        % check for ids in id_meas2 that are not present in id_meas1
    for j = 1:length(diff1)
        idx = (zdata(:,1) == type1 & zdata(:,3) == diff1(j));   % find measurement to be deleted
        zdata(idx,:) = [];                                      % delete single measurement of the pair
    end
    for j = 1:length(diff2)
        idx = (zdata(:,1) == type2 & zdata(:,3) == diff2(j));   % find measurement to be deleted
        zdata(idx,:) = [];                                      % delete single measurement of the pair
    end
end