%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ICAS24: airspace capacity 
% Anastasia Lemetti
% MATLAB version: MATLAB R2023b
% 
% plot all flights within lon 9-13, lat 47-50, time 15.00-17-30, day
% 2023-06-08

clc; clear; close all;

filename = fullfile('.', 'temp', 'flights_case1.csv');
flight_plans = readtable(filename);

callsigns = unique(flight_plans.callsign);

flight_nums = length(callsigns);

figure; hold on;

min_lon = 9;
max_lon = 13;
min_lat = 47;
max_lat = 50;

latlim = [min_lat max_lat];
lonlim = [min_lon max_lon];

for i=1:flight_nums
    flight = flight_plans(strcmp(flight_plans.callsign, callsigns(i)), :);
    fig = plot(flight.beginLon, flight.beginLat, 'linewidth', 2);
end

filename = 'temp';
saveas(fig, fullfile('.', 'figures', 'temp', filename), 'png');
clf(fig)


