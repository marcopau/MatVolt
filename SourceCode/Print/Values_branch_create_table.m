function tabline = Values_branch_create_table(branch, gridval)
% This function creates a table with the electrical quantities at the
%  branches of the electrical grid.
%
% SYNTAX:
%   tabline = Values_branch_create_table(branch, gridval)
% 
% INPUTS:
%   branch : structure with the following data about the grid branches 
%       branch.num = number of branches in the grid.
%       branch.start = vector with the numerical indexes of the nodes at  
%                       the sending end of each branch.
%       branch.end = vector with the numerical indexes of the nodes at the 
%                     receiving end of each branch.
%       branch.id = vector with the numerical indexes associated to each
%                    branch.
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
% OUTPUTS: 
%   tabline : table with electric grid branch results. It includes ->
%       Line id : id number of the branch
%       Node start : sending or start node id of the branch
%       Node end : receiving or end node id of the branch
%       P1 : active branch power at the sending node
%       Q1 : reactive branch power at the sending node
%       cosphi1 : power factor of the branch power at the sending node
%       P2 : active branch power at the receiving node
%       Q2 : reactive branch power at the receiving node
%       cosphi2 : power factor of the branch power at the receiving node
%       Losses : power losses along the branch
%       Iabs1 : current megnitude of the branch current at the sending node
%       Iangle1 : current phase angle of the branch current at the sending node 
%       Iabs2 : current megnitude of the branch current at the receiving node
%       Iangle2 : current phase angle of the branch current at the receiving node 

%% Computation branch quantities
Line = branch.id;
Node_start = branch.start;
Node_end = branch.end;
P1 = gridval.S.br1.real;
Q1 = gridval.S.br1.imag;
cosphi1 = gridval.S.br1.real./gridval.S.br1.mag;
P2 = gridval.S.br2.real;
Q2 = gridval.S.br2.imag;
cosphi2 = gridval.S.br2.real./gridval.S.br2.mag;
Losses = abs(P1+P2);
Iabs1 = gridval.I.br1.mag;
Iangle1 = gridval.I.br1.phase;
Iabs2 = gridval.I.br2.mag;
Iangle2 = gridval.I.br2.phase;

%% Create table
tabline = table(Line,Node_start,Node_end,P1,Q1,cosphi1,P2,Q2,cosphi2,Losses,Iabs1,Iangle1,Iabs2,Iangle2);