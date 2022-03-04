function val = Round_grid_val(val)
% This function cleans the values in input by putting to zero very low
%   magnitude values and putting NaN for the angles of zeroed values.
%
% SYNTAX:
%   val = Round_grid_val(val)
%
% INPUT & OUTPUT:
%   val : structure with the vectors of the electrical quantity in
%          different formats (mag, phase, real, imag, complex)

%% Data cleaning process
data_avg = mean(val.mag);
index = find(val.mag < data_avg/1e8);   
val.mag(index) = 0;
val.phase(index) = NaN;
val.real(index) = 0;
val.imag(index) = 0;
val.complex(index) = 0;