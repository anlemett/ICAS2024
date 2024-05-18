%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ICAS24: airspace capacity 
% Anastasia Lemetti
% MATLAB version: MATLAB R2024a
% 
% Inputs:
%   1) Weather polygons (xml)
% 
%   2) Flight data: Flight plans (so6)
% 
%   3) Airspace data (json)
%
% Output:
%   Available ACC capacity ratio ASCR
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [sector_names, sector_time, sector_data] = icas_main_function()

    clear; clc; close all;
    warning('off');

    nT = 10;

    % Time: from 15.00 to 17.15 (end time to 17.30)
    minut_vec = 00:15:15*(nT-1); % Minutes from 15.00
    
    t_string = [repmat('2023-06-08 15:', [nT, 1]), num2str(minut_vec', '%02.0f'),...
        repmat(':00', [nT, 1])];
    t_vec_ini = datenum(t_string, 'yyyy-mm-dd HH:MM:SS');

    % Airspace configuration
    lower_sector_filename = fullfile('.', 'code_input', 'airspace_data',...
        'Lower_airspace', 'fir_EDMM_2023-06-08.json');
    lower_sector = jsondecode(fileread(lower_sector_filename));
    acc_struct = lower_sector.x2023_06_08.EDMMCTAA;

    % For each time, find sector configuration in table 'configuration_20230608_1500_1730.xlsx'
    % for LOW_EDMMCTAA only

    T = readtable(fullfile('.', 'code_input', 'airspace_data',...
        'configuration_20230608_1500_1730.xlsx'), ...
        'FileType', 'spreadsheet', 'Range','A2:C11'); % Read xlsx file
  
    T.Properties.VariableNames = {'time_ini', 'time_fin', 'config'}; % names of columns
    
    config_vec = cell(size(t_vec_ini));

    t_day = datenum('2023-06-08 00:00:00', 'yyyy-mm-dd HH:MM:SS');
    
    for t = 1:nT
        t_find = t_vec_ini(t); 
        index = (t_find>=(T.time_ini+t_day))&(t_find<(T.time_fin+t_day));
        config_vec(t) = T.config(index);
    end

    % Read weather data

    weather_polygons = icas_function_get_weather_data();

    % Read airspace data and calculate ASCR

    % all flight levels:  0    45    65    95   105   195
    flight_levels = [0 45 65 95 105 195];
    nAB = numel(flight_levels)-1; % number of altitude bands

    acc_pgons = cell(nT, nAB);

    % ASCR Available sector (ACC) capacity ratio
    ASCR = nan(1, nT);

    flows = cell(nT, nAB, 4); % 4 = 2 parts + inverse flows

    for t=1:nT

        config_name = config_vec{t};
        
        ASCR_a_band = nan(1, nAB);

        for h=1:nAB

            start_flight_level = flight_levels(h);
            end_flight_level = flight_levels(h+1);

            acc_pgons{t, h} = icas_function_get_acc_polygon(acc_struct, config_name,...
                start_flight_level, end_flight_level);

            % TODO: find weights
            % temporary:
            W = [0.25, 0.25;  % flow1, inverse flow1
                 0.25, 0.25]; % flow2, inverse flow2

            ASCR_a_band(h) = icas_function_get_ASCR(h, weather_polygons{t}, flows, W);
            
        end
           
        ASCR(t) = sum(ASCR_a_band);

    end

disp(ASCR);
end
