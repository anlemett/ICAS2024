% TODO !!!

% Function to read flight plan data.

function AC = function_read_FP(flight_plans_folder)

% na = 1; % number of AC
%
ac_files = dir([flight_plans_folder, '/*.json']);
na = numel(ac_files); % number of AC

AC(na) = struct;

for ia = 1:na
    
    file_name = [flight_plans_folder, '/', ac_files(ia).name];
    val = jsondecode(fileread(file_name));
    
    waypoint_list = fieldnames(val.flight_data.Eurocontrol_trajectory);
    nWP = numel(waypoint_list); % Number of waypoints
    
    AC(ia).WP = zeros(nWP, 4); % [lon, tal, h, time]
    
    for i = 1:nWP
        
        WP_info = val.flight_data.Eurocontrol_trajectory.(waypoint_list{i});
        
        AC(ia).WP(i,1) = datenum(WP_info.time,'yyyy-mm-dd HH:MM:SS');
        AC(ia).WP(i,2) = WP_info.lon;
        AC(ia).WP(i,3) = WP_info.lat;
        AC(ia).WP(i,4) = WP_info.FL;
        
    end
    
end

end