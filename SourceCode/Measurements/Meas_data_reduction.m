function zdata = Meas_data_reduction(zdata, types_to_keep)
% This function returns a zdata matrix with only a subset of all the
%  existing measurements, according to desired types of measurements.
%
% SYNTAX:
%   zdata = Meas_data_reduction(zdata, types_to_keep)
%
% INPUTS:
%   zdata : original matrix of the measurement info in input to a SE 
%            algorithm (see Table columns below).
%           Check "help Meas_data_creation" for more details on the
%            meaning of the different columns. 
%                  --------- ------- -------- -------   
%                 | Type of | Meas  | Meas |  Meas   |
%                 |   meas  | value |  id  | std dev |
%                  --------- ------- -------- -------  
%   
%   types_to_keep : vector of desired id meas types to be left in zdata.
%
% OUTPUTS:
%   zdata : modified matrix of the measurement info in input to a SE 
%            algorithm (see Table columns below).
%           Check "help Meas_data_creation" for more details on the
%            meaning of the different columns.  
%                  --------- ------- -------- -------   
%                 | Type of | Meas  | Meas |  Meas   |
%                 |   meas  | value |  id  | std dev |
%                  --------- ------- -------- -------  

%% Reduction of the measurement set
for i = 1:12                        % number of meas types currently in use
    if ~ismember(i, types_to_keep)
        nomeas = zdata(:,1) == i;
        zdata(nomeas,:) = [];
    end
end