function gridval = Round_grid_val_call(gridval)
% This function manages the calls to the 'Round_grid_val' function for all
%  the relevant fields within the gridval structure.
%
% SYNTAX:
%   gridval = Round_grid_val_call(gridval)
%
% INPUT & OUTPUT
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

%% Execution of the function calls
gridval.S.inj = Round_grid_val(gridval.S.inj);
gridval.S.br1 = Round_grid_val(gridval.S.br1);
gridval.S.br2 = Round_grid_val(gridval.S.br2);
gridval.I.inj = Round_grid_val(gridval.I.inj);
gridval.I.br1 = Round_grid_val(gridval.I.br1);
gridval.I.br2 = Round_grid_val(gridval.I.br2);