%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ICAS24: airspace capacity 
% Anastasia Lemetti
% MATLAB version: MATLAB R2023b
% 
% determine flight levels in lower sector configurations for 2023-06-08

% Airspace configuration
lower_sector_filename = fullfile('.', 'code_input', 'airspace_data', 'Lower_airspace', ...
    'fir_nextto_EDMMCTAA_2023-06-08.json');

lower_sector = jsondecode(fileread(lower_sector_filename));

exp_date = 'x2023_06_08';

acc_struct_arr = [lower_sector.(exp_date)];
acc_arr = fieldnames([lower_sector.(exp_date)]);

flight_levels = {};
flight_levels_from = {};
flight_levels_to = {};

%for i = 1:numel(acc_arr)
    %struct_acc = acc_arr{i};
    %acc = char(struct_acc);
    
    struct_acc = acc_struct_arr.EDMMCTAA;
    acc = 'EDMMCTAA';

    confs = [lower_sector.(exp_date).(acc).configurations];

    conf_names = fieldnames(confs);

    % Loop over the fields
    for ii = 1:numel(conf_names)

        conf = confs.(conf_names{ii});

        el_sectors = [conf.elementarySectors];

        el_sectors_names = fieldnames(el_sectors);

        for j = 1:numel(el_sectors_names)

            el_sector = el_sectors.(el_sectors_names{j});

            airblocks = [el_sector.airblocks];

            airblocks_names = fieldnames(airblocks);

            for jj = 1: numel(airblocks_names)
                airblock = airblocks.(airblocks_names{jj});
                flight_levels{numel(flight_levels)+1} = airblock.fl(1);
                flight_levels{numel(flight_levels)+1} = airblock.fl(2);
                %flight_levels_from{numel(flight_levels_from)+1} = airblock.fl(1);
                %flight_levels_to{numel(flight_levels_to)+1} = airblock.fl(2);
            end
        end
    end
%end

flight_levels = unique(cell2mat(flight_levels));
disp(flight_levels); % 0    45    65    95   105   195
%flight_levels = unique(cell2mat(flight_levels_from));
%disp(flight_levels);
%flight_levels = unique(cell2mat(flight_levels_to));
%disp(flight_levels);

% Find the coordinates of EDMMCTAA, configuration A1, FL 105

acc = 'EDMMCTAA';
confs = [lower_sector.(exp_date).(acc).configurations];

conf_names = fieldnames(confs);

% Loop over the fields
for ii = 1:numel(conf_names)

    conf = confs.(conf_names{ii});

    for h=1:numel(flight_levels)

        FL = flight_levels(h);

        FL_polygon = polyshape();

        el_sectors = [conf.elementarySectors];

        el_sectors_names = fieldnames(el_sectors);

        for j = 1:numel(el_sectors_names)

            el_sector = el_sectors.(el_sectors_names{j});

            airblocks = [el_sector.airblocks];

            airblocks_names = fieldnames(airblocks);

            for jj = 1: numel(airblocks_names)
                airblock = airblocks.(airblocks_names{jj});

                if (airblock.fl(1) <= FL) && (FL <= airblock.fl(2))
              
                    airblock_coord = airblock.polygon;
                    airblock_coord(:, [1, 2]) = airblock_coord(:, [2, 1]);

                    % Remove duplicate vertices
                    airblock_coord = unique(airblock_coord, 'rows', 'stable');

                    airblock_pgon = polyshape(airblock_coord);

                    FL_polygon = union(FL_polygon, airblock_pgon);
                end
            end
        end
    
        % Extract vertices from the original polyshape
        vertices = FL_polygon.Vertices;

        % Remove duplicate vertices
        cleanedVertices = unique(vertices, 'rows', 'stable');

        % Create a new polyshape object without duplicate vertices
        FL_polygon = polyshape(cleanedVertices);

        % Display the combined polygon
        figure; hold on;
        min_lon = 9;
        max_lon = 13;
        min_lat = 47;
        max_lat = 50;
        latlim = [min_lat max_lat];
        lonlim = [min_lon max_lon];
        xlim(lonlim), ylim(latlim);
        daspect([1 cos(mean(latlim)*pi/180) 1]);
        xlabel('Longitude [º]');
        ylabel('Latitude [º]');

        fig = plot(FL_polygon, 'FaceColor', 'c', 'FaceAlpha', 0.5);

        % Runways (https://skyvector.com/airport/EDDM/Muenchen-Airport)
        % Runway 08R: N48°20.44' / E11°45.06', Runway 26L: N48°20.69' / E11°48.28'
        % Runway 08L: N48°21.77' / E11°46.05', Runway 26R: N48°22.01' / E11°49.27'
        rwy_08R_lat = dm2degrees([48, 20.44]);
        rwy_08R_lon = dm2degrees([11, 45.06]);
        rwy_26L_lat = dm2degrees([48, 20.69]);
        rwy_26L_lon = dm2degrees([11, 48.28]);
        rwy_08L_lat = dm2degrees([48, 21.77]);
        rwy_08L_lon = dm2degrees([11, 46.05]);
        rwy_26R_lat = dm2degrees([48, 22.01]);
        rwy_26R_lon = dm2degrees([11, 49.27]);

        vertices = [rwy_08R_lon rwy_08R_lat; 
                    rwy_26L_lon rwy_26L_lat;
                    rwy_26R_lon rwy_26R_lat;
                    rwy_08L_lon rwy_08L_lat];

        rwy1_lons = [rwy_08R_lon rwy_26L_lon]; 
        rwy1_lats = [rwy_08R_lat rwy_26L_lat];
        rwy2_lons = [rwy_26R_lon rwy_08L_lon];
        rwy2_lats = [rwy_26R_lat rwy_08L_lat];

        rwys = polyshape(vertices);

        %fig = plot(rwys, 'FaceColor', 'r', 'FaceAlpha', 0.5);
        fig = plot(rwy1_lons, rwy1_lats);
        fig = plot(rwy2_lons, rwy2_lats);

        % Take one rwy
        point1 = [rwy_08R_lon rwy_08R_lat];
        point2 = [rwy_26L_lon rwy_26L_lat];

        % Calculate the midpoint of the line
        midpoint = [(point1(1) + point2(1)) / 2, (point1(2) + point2(2)) / 2];

        % Calculate the slope of the line
        m = (point2(2) - point1(2)) / (point2(1) - point1(1));

        % Calculate the slope of the perpendicular line
        perpendicular_slope = -1 / m;

        % Calculate the y-intercept of the perpendicular line using the midpoint
        b_perpendicular = midpoint(2) - perpendicular_slope * midpoint(1);

        % Define x-values for plotting
        x_minvalues = linspace(9, 13, 100);
        % Calculate y-values of the perpendicular line
        y_min_lon = perpendicular_slope * min_lon + b_perpendicular;
        y_max_lon = perpendicular_slope * max_lon + b_perpendicular;
        
        [loni,lati] = polyxpoly([min_lon max_lon],...
                                 [y_min_lon y_max_lon],...
                                 cleanedVertices(:,1),...
                                 cleanedVertices(:,2));
        plot(loni, lati,'-ko', 'MarkerSize', 10);
                
        plot_title = strcat("EDMMCTAA ", conf_names{ii});
        plot_title = strcat(plot_title, " FL");
        plot_title = strcat(plot_title, string(FL));
        title(plot_title);
        axis equal;
        
        name = strcat("EDMMCTAA_", conf_names{ii});
        name = strcat(name, "_FL");
        filename = strcat(name, string(FL));

        saveas(fig, fullfile('.', 'figures', 'FL', filename), 'png');
        clf(fig)
    end
end
