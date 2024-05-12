function [sector_names, sector_time, sector_data] = icas_main_function()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ICAS24: airspace capacity 
% Anastasia Lemetti
% MATLAB version: MATLAB R2023b
% 
% Inputs:
%   1) Weather polygons (xml)
% 
%   2) Flight data: Flight plans (so6)
% 
%   3) Airspace data
%
% Output:
%   Available sector capacity ratio ASCR{k}(t) for each sector k at time t

    % Time: from 15.00 to 17.30
    minut_vec = 00:15:150; % Minutes from 15.00

    t_string = [repmat('2023-06-08 15:', size(minut_vec')), num2str(minut_vec', '%02.0f'), repmat(':00', size(minut_vec'))];
    t_vec_ini = datenum(t_string, 'yyyy-mm-dd HH:MM:SS');

    t_string = [repmat('2018-06-08 15:', size(minut_vec')), num2str((minut_vec'+15), '%02.0f'), repmat(':00', size(minut_vec'))];
    t_vec_fin = datenum(t_string, 'yyyy-mm-dd HH:MM:SS');


    % Airspace configurations
    % ACC: configuration (time)
    % Lower airspace
    % EDMMCTAA: A5I (15.00 - 15.59), A5NH (16.00 - 17.30)
    % EDMMCTAE: E5L (15.00 - 17.30)
    % EDMMCTAW: W6 (15.00 - 17.30)
    % Upper airspace
    % EDUUUTAC: C8D (15.00 - 15.59), C7J(16.00 -16.29), C6E (16.30 - 17.30)
    % EDUUUTAE: E6(15.00 - 15.14), E7D(15.15 - 15.29, 17.00 - 17.29), E6F(15.30 - 16.59)
    % EDUUUTAS: S6H (15.00 - 17.29)
    % EDUUUTAW: W6B (15.00 - 17.29)

