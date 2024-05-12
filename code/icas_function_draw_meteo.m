function icas_function_draw_meteo()
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

    close all;

    % Time: from 15.00 to 17.30
    minut_vec = 00:15:135; % Minutes from 15.00

    t_string = [repmat('2023-06-08 15:', size(minut_vec')), num2str(minut_vec', '%02.0f'), repmat(':00', size(minut_vec'))];
    t_vec_ini = datenum(t_string, 'yyyy-mm-dd HH:MM:SS');

    t_string = [repmat('2018-06-08 15:', size(minut_vec')), num2str((minut_vec'+15), '%02.0f'), repmat(':00', size(minut_vec'))];
    t_vec_fin = datenum(t_string, 'yyyy-mm-dd HH:MM:SS');

    % Airspace configuration
    lower_sector_filename = fullfile('.', 'code_input', 'airspace_data', 'Lower_airspace', 'fir_EDMM_2023-06-08.json');
    upper_sector_filename = fullfile('.', 'code_input', 'airspace_data', 'Upper_airspace', 'fir_EDUU_2023-06-08.json');

    % For each time, find sector configuration in table 'configuration_20230608_1500_1730.xlsx'
    % for LOW_EDMMCTAA only (temporarly)

    T = readtable(fullfile('.', 'code_input', 'airspace_data', 'configuration_20230608_1500_1730.xlsx'), ...
        'FileType', 'spreadsheet', 'Range','A2:C11'); % Read xlsx file
    T.Properties.VariableNames = {'time_ini', 'time_fin', 'config'}; % names of columns
    
    config_vec = cell(size(t_vec_ini));

    t_day = datenum('2023-06-08 00:00:00', 'yyyy-mm-dd HH:MM:SS');
    
    for t = 1:length(t_vec_ini)
        t_find = t_vec_ini(t); 
        index = (t_find>=(T.time_ini+t_day))&(t_find<(T.time_fin+t_day));
        config_vec(t) = T.config(index);
    end

    %% Read airspace sectors

    % Read geography

    % Load airspace sectors

    example_altitude = 400;

    config_name = config_vec{1}; % Example sector configuration
    
    % TODO: add upper_sector_filename
    [sector_names, sector_time, sector_data] = icas_function_all_configurations(config_vec, lower_sector_filename);

    %disp(sector_names)

    % TODO: Create adjacent sectors

    % TODO: read only relevant weather data
    %% Read weather data

    weather_polygons = icas_function_weather_data();

    %% Display all data
    
    for t=1:10

        figure, hold on

    min_lat = 180; min_lon = 180; max_lat = 0; max_lon = 0; % no negatives due to geography
    for i = 1:length(sector_data)
        latitudes = sector_data{i}(:,1);
        longitudes= sector_data{i}(:,2);
        
        sector_min_lat = min(latitudes);
        sector_min_lon = min(longitudes);
        sector_max_lat = max(latitudes);
        sector_max_lon = max(longitudes);

        min_lat = min(min_lat, sector_min_lat);
        min_lon = min(min_lon, sector_min_lon);
        max_lat = max(max_lat, sector_max_lat);
        max_lon = max(max_lon, sector_max_lon);
    end
    
    min_lon = min_lon - 1;
    max_lon = max_lon + 1;
    min_lat = min_lat - 1;
    max_lat = max_lat + 1;

    latlim = [min_lat max_lat];
    lonlim = [min_lon max_lon];

    xlim(lonlim), ylim(latlim);
    daspect([1 cos(mean(latlim)*pi/180) 1]);

    xlabel('Longitude [º]')
    ylabel('Latitude [º]')

    % sectors
    %sector_color = lines(length(sector_example));

    % create sectors_pgon - 1xN cell array, each cell - polyshape

    % temp, TODO: change
    temp = length(sector_data);
    for ii = 1:length(sector_data)
        if ~isempty(sector_data{ii})
           latitudes = sector_data{ii}(:,1)
           longitudes = sector_data{ii}(:,2)
           fig = plot(longitudes, latitudes, 'linewidth', 2);
            
           %filename = strcat('temp', int2str(ii));
           %full_filename = fullfile('.', 'figures', filename);
           %saveas(fig, full_filename, 'png');
           %clf(fig);
           %fig = plot(sectors_pgon{ii}, 'FaceColor', sector_color(ii,:));
           %[x,y] = centroid(sector_data{ii});
           %disp(sector_names_combi(ii))
           %text(x,y, sector_names_combi(ii));
        end
    end

    % Adjacent sectors
    % TODO
    
    % obstacles

    
        
        number_of_obstacles_with_margins = length(weather_polygons{t,1});
        %number_of_obstacles_with_margins = length(weather_polygons{1,1});
        %number_of_obstacles_with_margins = 2
        for o = 2:number_of_obstacles_with_margins
            w_pgon_with_margins = weather_polygons{t,1}{o};
            %w_pgon_with_margins = weather_polygons{1,1}{o};
            if isempty(w_pgon_with_margins)
                continue
            end

            % plot obstacles with margins
            %fig = plot(w_pgon_with_margins.pgon, 'EdgeColor', [199, 0, 57 ]/255, 'FaceColor', [199, 0, 57]/255, 'FaceAlpha', 0.1);
            fig = plot(w_pgon_with_margins.pgon, 'EdgeColor', [199, 0, 57 ]/255, 'FaceColor', [199, 0, 57]/255, 'FaceAlpha', 0.3);
        end

        filename = strcat('meteo', string(t));
        saveas(fig, fullfile('.', 'figures', filename), 'png');
        clf(fig)

    end
end

