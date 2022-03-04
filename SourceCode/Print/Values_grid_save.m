function Values_grid_save(branch, node, gridval, type, file1, file2, dir)
% This function saves the electric grid values for a given grid (e.g., the
%  results of power flow or state estimation algorithms) in two files, one
%  with the node and one with the branch results.
%  Accepted file types are:
%       .txt, .dat, or .csv for delimited text files
%       .xls, .xlsm, or .xlsx for Excel® spreadsheet files 
%
% SYNTAX:
%   Values_grid_save(branch, node, gridval, type)
%   Values_grid_save(branch, node, gridval, type, file1, file2)
%   Values_grid_save(branch, node, gridval, type, file1, file2, dir)
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
%   type : string with the extension of the file type. Accepted file types
%           are: .txt, .dat, or .csv for delimited text files
%                .xls, .xlsm, or .xlsx for Excel® spreadsheet files 
%
%   file1 : string with the name of the first file to save for grid node
%            values.
%
%   file2 : string with the name of the second file to save for grid branch
%            values.
%
%   dir : directory of the folder where to save the file (optional).
%          If no directory is provided, the file will be automatically
%          saved in the current directory.

%% Definition directory and filename
if nargin == 4 || nargin == 5
    dir1 = pwd;
    dir2 = dir1;
    name1 = branch.grid_name;
    name2 = name1;
    if nargin == 5
        msg = ['the given filename has been skipped and default filenames have been used. ' ...
        'Note: this function saves two different files, one with the grid node and another with the grid branch results; ', ...
        'please provide two names "filename1", "filename2".'];
        warning(msg)
    end
elseif nargin == 6 || nargin == 7
    [~,name1,~] = fileparts(file1);
    [~,name2,~] = fileparts(file2);
    if nargin == 6
        dir1 = pwd;
        dir2 = dir1;
    else
        dir1 = dir;
        dir2 = dir;
    end
end
filename1 = strcat(dir1,'\',name1,'_node_results',type);
filename2 = strcat(dir2,'\',name2,'_branch_results',type);

%% Create node results
tabnode = Values_node_create_table(node, gridval);

%% Create branch results
tabline = Values_branch_create_table(branch, gridval);

%% Save data
writetable(tabnode,filename1)
writetable(tabline,filename2)     