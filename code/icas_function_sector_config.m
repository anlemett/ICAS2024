% This function obtains the list of sectors and their characteristics for a
% given sector configuration

function [sector_out, sector_names_combi] = icas_function_sector_config(config_name, sector_filename)

% Inputs: 1) config_name: Given sector configuration (name)
%         2) sector_filename: name of the .json file containing sector data
% Output: sector_out. 1xN cell, where N is the number of elementary sectors in our configuration

% read sector_filename file
val = jsondecode(fileread(sector_filename)); % e.g. 'fir_EDMM_2023-06-08.json'

% TODO: date and acc - function parameters
% temp:
% Matlab changes the field name, according to its own rules (should not start with a number,
% no '-' symbol). Original: '2023-06-08'
% TODO: write the transformation for any date
exp_date = 'x2023_06_08'; 
acc = 'EDMMCTAA';

aux = [val.(exp_date).(acc).configurations.(config_name).elementarySectors];
N = length(aux); % Number of elementary sectors in our configuration
sector_out = cell(1,N); % Initialize output variable

% TODO: create sector polygons from elementary sectors' airblocks

% temp:
sector_names_combi = fieldnames(aux)';
i=1;
for sector_name = sector_names_combi
    el_sector = char(sector_name);
    sector_out{i} = [val.(exp_date).(acc).configurations.(config_name).elementarySectors.(el_sector).polygon_sector];
    i = i + 1;
end

end
