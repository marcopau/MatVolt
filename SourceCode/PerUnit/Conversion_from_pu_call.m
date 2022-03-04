function gridval = Conversion_from_pu_call(gridval, base)
% This function manages the calls to the 'Conversion_from_pu' function for 
%  all the fields within the 'gridval' structure.
%
% SYNTAX:
%   gridval = Conversion_from_pu_call(gridval, base)
%
% INPUT
%   base : structure with the different base values, including ->
%       base.S = base power
%       base.V = base voltage
%       base.I = base current
%       base.Z = base impedance
%       base.Y = base admittance
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
gridval.V = Conversion_from_pu(gridval.V, base.V);
gridval.S.inj = Conversion_from_pu(gridval.S.inj, base.S);
gridval.S.br1 = Conversion_from_pu(gridval.S.br1, base.S);
gridval.S.br2 = Conversion_from_pu(gridval.S.br2, base.S);
gridval.I.inj = Conversion_from_pu(gridval.I.inj, base.I);
gridval.I.br1 = Conversion_from_pu(gridval.I.br1, base.I);
gridval.I.br2 = Conversion_from_pu(gridval.I.br2, base.I);
