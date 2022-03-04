function zdata = Bad_data_remove(zdata, idx)
% This function removes the measurement in the position "idx" from 
%  the measurement matrix zdata. 
% If this measurement corresponds to a pair measurement (power or phasor),
%  also the other measurment of the pair is removed.
%
% SYNTAX:
%   zdata = Bad_data_remove(zdata, idx)
% 
% INPUT:
%   idx : index of the measurement to be removed
%
% INPUT & OUTPUT
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

%% Measurement removal process
meas_pair = [2,3,4,5,7,8,9,10,11,12];       % measurements that are considered as combined with another
type = zdata(idx,1);
if ismember(type, meas_pair)                % if the measurement to be removed belongs to a pair, procedure to identify the other measurement of the pair
    meas_id = zdata(idx,3);
    switch type
        case 2
            type2 = 3;
        case 3
            type2 = 2;
        case 4
            type2 = 5;
        case 5
            type2 = 4;
        case 7
            type2 = 8;
        case 8
            type2 = 7;
        case 9 
            type2 = 10;
        case 10
            type2 = 9;
        case 11
            type2 = 12;
        case 12 
            type2 = 11;
    end
    idx2 = find(zdata(:,1) == type2 & zdata(:,3) == meas_id);     % find the other measurement of the pair
else 
    idx2 = [];
end
idx = [idx; idx2];
zdata(idx,:) = [];      % remove the measurements