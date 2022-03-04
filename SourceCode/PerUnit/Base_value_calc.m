function base = Base_value_calc(Srated, Vrated)
% This function computes all the base values of a network given the base
%  power and voltage (three-phase grid).
%
% SYNTAX:
%   base = Base_value_cal(Srated, Vrated)
% 
% INPUTS:
%   Srated : base power to be used for per unit conversion.
%   Vrated : base line-to-line voltage to be used for per unit conversion. 
%
% OUTPUTS:
%   base : structure with the following base values ->
%       base.S = base power
%       base.V = base voltage
%       base.I = base current
%       base.Z = base impedance
%       base.Y = base admittance

%% Base values computation
base.S = Srated;
base.V = Vrated;
base.I = base.S/(sqrt(3)*base.V);
base.Z = (base.V^2)/base.S;
base.Y = 1/base.Z;