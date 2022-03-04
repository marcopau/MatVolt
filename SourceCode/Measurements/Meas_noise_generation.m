function zdata_out = Meas_noise_generation(zdata_in)
% This function modifies the zdata matrix by adding measurement white 
%   Gaussian noise to meas values according to the information on the meas
%   standard deviation
%
% SYNTAX:
%   zdata_out = Meas_noise_generation(zdata_in)
%
% INPUTS:
%   zdata_in : original matrix of the measurement info in input to a SE 
%               algorithm (see Table columns below).
%              Check "help Meas_data_creation" for more details on the
%               meaning of the different columns. 
%                  --------- ------- -------- -------   
%                 | Type of | Meas  | Meas |  Meas   |
%                 |   meas  | value |  id  | std dev |
%                  --------- ------- -------- -------    
%
% OUTPUTS:
%   zdata_out : modified matrix of the measurement info in input to a SE 
%                algorithm (see Table columns below).
%               Check "help Meas_data_creation" for more details on the
%                meaning of the different columns. 
%                  --------- ------- -------- -------   
%                 | Type of | Meas  | Meas |  Meas   |
%                 |   meas  | value |  id  | std dev |
%                  --------- ------- -------- -------    

%% Addition random noise to measurements
ztrue = zdata_in(:,2);
dev_std = zdata_in(:,4);
z = ztrue + dev_std.*randn(size(ztrue));   % addition of random noise to the true value according to uncertainty distribution
zdata_out = zdata_in;                      % same matrix as zdata_in -> only the measurement values are changed with the noise corrupted ones
zdata_out(:,2) = z;