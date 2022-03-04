function [from, to] = Bus_of_branch(branch, br)
% This function identifies the sending and receiving nodes of the branches  
%  in vector 'br'. A negative sign on the branch id 'br' inverts the 
%  convention on sending and receiving node.
%
% SYNTAX:
%   [from, to] = Bus_of_branch(branch, br)
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
%   br : vector of the branches id.
%
% OUTPUTS:
%   from : vector of the sending nodes id of the branches.
%   to : vector of the receiving nodes id of the branches.

%% Node identification
nbr = length(br);                                % number of input branches to be processed
from = zeros(nbr,1);                             % initialization from vector
to = zeros(nbr,1);                               % initialization to vector
for i = 1:nbr
    if br(i) > 0                                 % if the branch id is positive, the branch has same direction of the convention used in the branch structure
        from(i,1) = branch.start(br(i));
        to(i,1) = branch.end(br(i));
    else                                         % if the branch id is negative, the branch has opposite direction of the convention used in the branch structure
        from(i,1) = branch.end(-br(i)); 
        to(i,1) = branch.start(-br(i));
    end
end