%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ICAS24: airspace capacity 
% Anastasia Lemetti
% MATLAB version: MATLAB R2024a
% 
% split acc polygon into two parts by runway and two perpendiculars
% return all 4 possible flows
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [flow1, flow2, flow3, flow4] = icas_function_get_flows(acc_pgon)

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

rwy_point1 = [rwy_08R_lon rwy_08R_lat];
rwy_point2 = [rwy_26L_lon rwy_26L_lat];
            
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
%y1_max_lon = perpendicular_slope * max_lon + b_perpendicular1;

% Calculate y-values of the perpendicular line2
%y2_min_lon = perpendicular_slope * min_lon + b_perpendicular2;
y2_max_lon = perpendicular_slope * max_lon + b_perpendicular2;

vertices = acc_pgon.Vertices;

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
            
source1 = [vertices_sorted(idx2:end,:); vertices_sorted(1:idx1, :)];
source2 = [vertices_sorted(idx1:idx2,:)];

sink12 = [rwy_point1; rwy_point2];

source34 = sink12;

sink3 = source1;
sink4 = source2;

top = [vertices_sorted(idx1, :); rwy_point1];
bottom = [rwy_point2; vertices_sorted(idx2, :)];

flow1 = struct;
flow1.S = source1; flow1.D = sink12; flow1.T = top; flow1.B = bottom;
flow2 = struct;
flow2.S = source2; flow2.D = sink12; flow2.T = top; flow2.B = bottom;
flow3 = struct;
flow3.S = source34; flow3.D = sink3; flow3.T = top; flow3.B = bottom;
flow4 = struct;
flow4.S = source34; flow4.D = sink4; flow4.T = top; flow4.B = bottom;

end


function vertices_sorted = sort_vertices(vertices)
N = size(vertices, 1);

c = mean(vertices,1); % mean/ central point 
d = vertices-c ; % vectors connecting the central point and the given points 
th = atan2(d(:,2),d(:,1)); % angle above x axis
[th, idx] = sort(th);   % sorting the angles 
vertices_sorted = vertices(idx,:); % sorting the given points
end