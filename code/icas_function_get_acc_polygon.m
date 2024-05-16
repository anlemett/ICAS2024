%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ICAS24: airspace capacity 
% Anastasia Lemetti
% MATLAB version: MATLAB R2024a
% 
% returns EDMMCTAA polygon of config_name configuration at flight_level
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function acc_polygon = icas_function_get_acc_polygon(acc_struct, config_name, flight_level)

    acc_polygon = polyshape();

    confs = [acc_struct.configurations];
    conf = confs.(config_name);

    el_sectors = [conf.elementarySectors];

    el_sectors_names = fieldnames(el_sectors);

    for i2 = 1:numel(el_sectors_names)

        el_sector = el_sectors.(el_sectors_names{i2});

        airblocks = [el_sector.airblocks];

        airblocks_names = fieldnames(airblocks);

        for i3 = 1: numel(airblocks_names)
            airblock = airblocks.(airblocks_names{i3});

            if (airblock.fl(1) <= flight_level) && (flight_level <= airblock.fl(2))
              
                airblock_coord = airblock.polygon;
                airblock_coord(:, [1, 2]) = airblock_coord(:, [2, 1]);

                % Remove duplicate vertices
                airblock_coord = unique(airblock_coord, 'rows', 'stable');
                airblock_pgon = polyshape(airblock_coord);
                acc_polygon = union(acc_polygon, airblock_pgon);
            end
        end
    end
    
    % Extract vertices from the original polyshape
    vertices = acc_polygon.Vertices;

    % Remove duplicate vertices
    cleanedVertices = unique(vertices, 'rows', 'stable');
    % Create a new polyshape object without duplicate vertices
    acc_polygon = polyshape(cleanedVertices);

end