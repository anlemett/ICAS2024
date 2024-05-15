function [acc_data] = icas_function_read_acc_data()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ICAS24: airspace capacity 
% Anastasia Lemetti
% MATLAB version: MATLAB R2023b
% 
% read main ACC coordinates

% Airspace configuration
lower_sector_filename = fullfile('.', 'code_input', 'airspace_data', 'Lower_airspace', 'fir_EDMM_2023-06-08.json');

lower_sector = jsondecode(fileread(lower_sector_filename));

exp_date = 'x2023_06_08';
acc = 'EDMMCTAA';
conf = 'A1';

acc_data = lower_sector.(exp_date).(acc).configurations.(conf).polygon_config;
end

