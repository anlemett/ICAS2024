%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ICAS24: airspace capacity 
% Anastasia Lemetti
% MATLAB version: MATLAB R2024a
% 
% plot EDUUUTAS on all flight levels for configuration 'S6H'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Airspace configuration
upper_sector_filename = fullfile('.', 'code_input', 'airspace_data', 'Upper_airspace', ...
    'fir_EDUU_2023-06-08.json');

upper_sector = jsondecode(fileread(upper_sector_filename));

exp_date = 'x2023_06_08';

acc_struct_arr = [upper_sector.(exp_date)];
acc_names = fieldnames(acc_struct_arr);

% Find the coordinates of ACC EDUUUTAS and all its sectors, configuration 'S6H'
main_acc = 'EDUUUTAS';
confs = [upper_sector.(exp_date).(main_acc).configurations];

main_conf_name = 'S6H';
main_conf = confs.(main_conf_name);




flight_levels = [0 45 65 95 105 195];

for i1=1:numel(flight_levels)

    FL = flight_levels(i1);

    FL_main_polygon = polyshape();
    FL_neighbour_pgons = {};

    el_sectors = [main_conf.elementarySectors];

    el_sectors_names = fieldnames(el_sectors);

    for i2 = 1:numel(el_sectors_names)

        el_sector = el_sectors.(el_sectors_names{i2});

        airblocks = [el_sector.airblocks];

        airblocks_names = fieldnames(airblocks);

        for i3 = 1: numel(airblocks_names)
            airblock = airblocks.(airblocks_names{i3});

            if (airblock.fl(1) <= FL) && (FL <= airblock.fl(2))
              
                airblock_coord = airblock.polygon;
                airblock_coord(:, [1, 2]) = airblock_coord(:, [2, 1]);

                % Remove duplicate vertices
                airblock_coord = unique(airblock_coord, 'rows', 'stable');
                airblock_pgon = polyshape(airblock_coord);
                FL_main_polygon = union(FL_main_polygon, airblock_pgon);
            end
        end
    end
    
    % Extract vertices from the original polyshape
    vertices = FL_main_polygon.Vertices;

    % Remove duplicate vertices
    cleanedVertices = unique(vertices, 'rows', 'stable');
    % Create a new polyshape object without duplicate vertices
    FL_main_polygon = polyshape(cleanedVertices);
    
    % Loop over the ACCs
    for i4 = 1:numel(acc_names)
         acc_struct = acc_struct_arr.(acc_names{i4});
         confs = [acc_struct_arr.(acc_names{i4}).configurations];
         conf_names = fieldnames(confs);
         for i5 = 1:numel(conf_names)

             conf = confs.(conf_names{i5});

             FL_polygon = polyshape();

             el_sectors = [conf.elementarySectors];

             el_sectors_names = fieldnames(el_sectors);

             for i6 = 1:numel(el_sectors_names)

                 el_sector = el_sectors.(el_sectors_names{i6});

                 airblocks = [el_sector.airblocks];

                 airblocks_names = fieldnames(airblocks);

                 for i7 = 1: numel(airblocks_names)
                     airblock = airblocks.(airblocks_names{i7});

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

             intersectionPoly = intersect(FL_main_polygon, FL_polygon);

             if ~isempty(intersectionPoly.Vertices)
                 FL_neighbour_pgons{length(FL_neighbour_pgons)+1} = FL_polygon;
             end
         end
    end

    % Display the combined polygon
    figure; hold on;
    colors = lines(length(FL_neighbour_pgons));
    fig = plot(FL_main_polygon, 'FaceColor', 'none', 'EdgeColor', 'k', 'linewidth', 2);
    for j=1:length(FL_neighbour_pgons)
        fig = plot(FL_neighbour_pgons{j}, 'FaceColor', 'none', 'EdgeColor', colors(j, :), 'linewidth', 2);
    end

    plot_title = strcat("EDMMCTAA ", main_conf_name);
    plot_title = strcat(plot_title, " FL");
    plot_title = strcat(plot_title, string(FL));
    title(plot_title);
    axis equal;
        
    name = strcat("EDMMCTAA_", main_conf_name);
    name = strcat(name, "_FL");
    filename = strcat(name, string(FL));

    saveas(fig, fullfile('.', 'figures', 'neighbours', filename), 'png');
    clf(fig)
end

close all;