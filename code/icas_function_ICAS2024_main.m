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
%   Available ACC capacity ratio ASCR(t) at time t
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [sector_names, sector_time, sector_data] = icas_main_function()

    close all;

    % Time: from 15.00 to 17.15 (end time to 17.30)
    minut_vec = 00:15:135; % Minutes from 15.00
    nT = 10; % Number of time intervals

    t_string = [repmat('2023-06-08 15:', size(minut_vec')), num2str(minut_vec', '%02.0f'), repmat(':00', size(minut_vec'))];
    t_vec_ini = datenum(t_string, 'yyyy-mm-dd HH:MM:SS');

    t_string = [repmat('2018-06-08 15:', size(minut_vec')), num2str((minut_vec'+15), '%02.0f'), repmat(':00', size(minut_vec'))];
    t_vec_fin = datenum(t_string, 'yyyy-mm-dd HH:MM:SS');

    % Airspace configuration
    lower_sector_filename = fullfile('.', 'code_input', 'airspace_data', 'Lower_airspace', 'fir_EDMM_2023-06-08.json');
    lower_sector = jsondecode(fileread(lower_sector_filename));
    acc_struct = lower_sector.x2023_06_08.EDMMCTAA;

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

    % Read airspace data

    % all flight levels:  0    45    65    95   105   195
    flight_levels = [0 45 65 95 105 195];

    acc_pgons = {};    

    for t=1:nT

        config_name = config_vec{t};

        for h=1:numel(flight_levels)

            flight_level = flight_levels(h);

            acc_pgons{t, h} = icas_function_get_acc_polygon(acc_struct, config_name, flight_level);

        end
    end

    % Read weather data

    weather_polygons = icas_function_get_weather_data();
    
    % Flight plans

    % TODO: read flight plans

    % Split ACC into two parts
    
    for t=1:nT

        for h=1:numel(flight_levels)

            flight_level = flight_levels(h);

            % Rwy
            % Runways (https://skyvector.com/airport/EDDM/Muenchen-Airport)
            % Runway 08R: N48°20.44' / E11°45.06', Runway 26L: N48°20.69' / E11°48.28'
            % Runway 08L: N48°21.77' / E11°46.05', Runway 26R: N48°22.01' / E11°49.27'

            rwy_08R_lat = dm2degrees([48, 20.44]);
            rwy_08R_lon = dm2degrees([11, 45.06]);
            rwy_26L_lat = dm2degrees([48, 20.69]);
            rwy_26L_lon = dm2degrees([11, 48.28]);

            rwy1_lons = [rwy_08R_lon rwy_26L_lon]; 
            rwy1_lats = [rwy_08R_lat rwy_26L_lat];

            fig = plot(rwy1_lons, rwy1_lats);

            rwy_point1 = [rwy_08R_lon rwy_08R_lat];
            rwy_point2 = [rwy_26L_lon rwy_26L_lat];
            %rwy_point2 = [rwy_08R_lon rwy_08R_lat];
            %rwy_point1 = [rwy_26L_lon rwy_26L_lat];
            
            % Calculate the slope of the line
            m = (rwy_point2(2) - rwy_point1(2)) / (rwy_point2(1) - rwy_point1(1));

            % Calculate the slope of the perpendicular line
            perpendicular_slope = -1 / m;

            % Calculate the y-intercept of the perpendiculars line using 
            % rwy's end point
            b_perpendicular1 = rwy_point1(2) - perpendicular_slope * rwy_point1(1);
            b_perpendicular2 = rwy_point2(2) - perpendicular_slope * rwy_point2(1);

            % Calculate y-values of the perpendicular line1
            y1_min_lon = perpendicular_slope * min_lon + b_perpendicular1;
            y1_max_lon = perpendicular_slope * max_lon + b_perpendicular1;

            % Calculate y-values of the perpendicular line2
            y2_min_lon = perpendicular_slope * min_lon + b_perpendicular2;
            y2_max_lon = perpendicular_slope * max_lon + b_perpendicular2;

            vertices = acc_pgons{t, h}.Vertices;

            [lon1,lat1] = polyxpoly([min_lon max_lon],...
                                 [y1_min_lon y2_max_lon],...
                                 vertices(:,1),...
                                 vertices(:,2));

            [lon2,lat2] = polyxpoly([min_lon max_lon],...
                                 [y1_min_lon y2_max_lon],...
                                 vertices(:,1),...
                                 vertices(:,2));

            point1 = [lon1(1) lat1(1)];
            point2 = [lon2(2) lat2(2)];
            
            %plot(lon1(1), lat1(1),'-ko', 'MarkerSize', 10);
            %plot(lon2(2), lat2(2),'-ko', 'MarkerSize', 10);

            dash_line1_x = [rwy_point1(1), point1(1)];
            dash_line1_y = [rwy_point1(2), point1(2)];
            dash_line2_x = [rwy_point2(1), point2(1)];
            dash_line2_y = [rwy_point2(2), point2(2)];

            plot(dash_line1_x, dash_line1_y);
            plot(dash_line2_x, dash_line2_y);

            % Add intersection points
            new_vertices = [vertices; point1; point2];
            vertices_sorted = sort_vertices(new_vertices);

            point1_idx = find(all(vertices_sorted == point1, 2), 1);
            point2_idx = find(all(vertices_sorted == point2, 2), 1);

            idx1 = min(point1_idx, point2_idx);
            idx2 = max(point1_idx, point2_idx);

            if point2_idx < point1_idx
                tmp = rwy_point1;
                rwy_point1 = rwy_point2;
                rwy_point2 = tmp;
            end
            
            % Create the first polygon
            new_poly1_vertices = [vertices_sorted(1:idx1, :); rwy_point1; rwy_point2; vertices_sorted(idx2:end,:)];
            new_poly1 = polyshape(new_poly1_vertices(:,1), new_poly1_vertices(:,2));

            % Create the second polygon
            new_poly2_vertices = [vertices_sorted(idx1:idx2,:); rwy_point2; rwy_point1];
            new_poly2 = polyshape(new_poly2_vertices(:,1), new_poly2_vertices(:,2));

            % TODO: add polygons to cell array
        

        end
    end

    % ASCR Available sector (ACC) capacity ratio

    ASCR = nan(nT);

    for t = 1:nT % For each time
    %for t = 1 % Only for the first time (15:00)
    
        [sector_ab, a_band, flows_j] = function_flows_sector_k(k_new, sector_data_t, adjacent_sectors);
        [p_in, p_out, AC_in] = function_p_in_out(AC, sector_ab, a_band);

        if t == 1 % initialie Wij_m
            Wij_m1 = function_Wij_ini(flows_j);
        end
        
        [~, Wij, total_ac] = function_Wj(t_vec_ini(t), t_vec_fin(t), p_in, p_out, a_band, flows_j, AC_in);
        
        if total_ac == 0 % If there are no aircraft in the sector, use the previous weights
            Wij = Wij_m1;
        end
        
        ASCR(t) = function_ASCR_k(sector_ab, flows_j, weather_polygons{t}, Wij, a_band);

        Wij_m1 = Wij;
        
    end
end


function vertices_sorted = sort_vertices(vertices)
N = size(vertices, 1);

c = mean(vertices,1); % mean/ central point 
d = vertices-c ; % vectors connecting the central point and the given points 
th = atan2(d(:,2),d(:,1)); % angle above x axis
[th, idx] = sort(th);   % sorting the angles 
vertices_sorted = vertices(idx,:); % sorting the given points
end