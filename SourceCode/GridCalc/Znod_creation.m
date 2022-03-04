function Znod = Znod_creation(branch, node)
% This function returns the State Estimation (SE) results for the grid data
%  given in input (single phase equivalent model).
% The SE algorithm is based on a Weighted Least Squared approach and uses
%  rectangular branch currents as state variables.
%
% SYNTAX:
%   Znod = Znod_creation(branch, node)
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
%   node : structure with the following data about the grid nodes 
%       node.num = number of the nodes in the grid.
%       node.type = matrix of cells with the following information. 
%                  -------------- --------------- ---------------   
%                 | Type of node | 1st set point | 2nd set point |
%                 |--------------|---------------|---------------|  
%                 |   'slack'    |    V (p.u.)   |  theta (rad)  |
%                 |    'PQ'      |    P (p.u.)   |    Q (p.u.)   |
%                 |    'PV'      |    P (p.u.)   |    V (p.u.)   |
%
% OUTPUTS: 
%   Znod : matrix with size (num_nodes X num_branches) where, for each row
%           i, there is the list of branch impedances in the path between
%           first node of the grid and node i.

%% Initialization matrices and vectors
Z = complex(branch.R,branch.X);                                            % vector of branch impedances
Znod = zeros(node.num,branch.num);                                         % initialization Znod matrix                      
br_queue = find(branch.start==1);                                          % initialization queue of branches in the path 
end_node_queue = branch.end(br_queue);                                     % initialization queue of end nodes in the path
start_node_queue = ones(length(end_node_queue),1);                         % initialization queue of start nodes in the path

%% Procedure to build the Znod matrix
while ~isempty(br_queue)
    m = start_node_queue(1);
    n = end_node_queue(1);
    k = br_queue(1);
    add_branches = find(branch.start==n);                                  % additional branches proceeding forward in the grid
    if ~isempty(add_branches)
        add_end_nodes = branch.end(add_branches);                          % end nodes of the found branches
        add_start_nodes = n*ones(length(add_end_nodes),1);                 % start node of the found branches
        br_queue = [br_queue; add_branches];                               % add branches to the queue
        end_node_queue = [end_node_queue; add_end_nodes];                  % add end nodes to the queue
        start_node_queue = [start_node_queue; add_start_nodes];            % add start nodes to the queue
    end    
    Znod(n,:) = Znod(m,:);                                                 % the end node will have the same path till the starting node
    Znod(n,k) = Z(k);                                                      % additionally, the end node will have the impedance of the associated branch
    start_node_queue(1) = [];
    end_node_queue(1) = [];
    br_queue(1) = [];
end