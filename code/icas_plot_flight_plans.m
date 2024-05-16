%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ICAS24: airspace capacity 
% Anastasia Lemetti
% MATLAB version: MATLAB R2024a
% 
% plot all flights within lon 9-13, lat 47-50, time 15.00-17-30, day
% 2023-06-08
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc; clear; close all;

filename = fullfile('.', 'temp', 'flights_case1.csv');
flight_plans = readtable(filename);

callsigns = unique(flight_plans.callsign);

flight_nums = length(callsigns);

%figure; hold on;

min_lon = 9;
max_lon = 13;
min_lat = 47;
max_lat = 50;

latlim = [min_lat max_lat];
lonlim = [min_lon max_lon];

for i=1:flight_nums
    figure;
    callsign = string(callsigns(i));
    flight = flight_plans(strcmp(flight_plans.callsign, callsign), :);
    %fig = plot(flight.beginLon, flight.beginLat, 'linewidth', 2);
    
    altitudes = flight.beginAltitude;
    num_way_points = length(altitudes);
    altitudes(num_way_points+1) = flight.endAltitude(num_way_points);
    times = 1:length(altitudes);
    fig = plot(times, altitudes, 'linewidth', 2);

    %filename = strcat(callsign, "_latlon");
    filename = strcat(callsign, "_altitude");
    saveas(fig, fullfile('.', 'figures', 'temp', filename), 'png');
    clf(fig)

end

%filename = 'temp';
%saveas(fig, fullfile('.', 'figures', 'temp', filename), 'png');

close all;



