%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ICAS24: airspace capacity 
% Anastasia Lemetti
% MATLAB version: MATLAB R2023b
% 
% plot all flights within lon 9-13, lat 47-50, time 15.00-17-30, day
% 2023-06-08

clc; clear; close all;

filename = fullfile('.', 'code_input', 'flight_plan_data', '20230608_m1.so6');
flight_plans = readtable(filename, 'Delimiter', ' ', 'FileType', 'text');

flight_plans.Properties.VariableNames = {'segmentId', ...
    'origin', 'destination', 'aircraftType', 'beginTime', 'endTime', ...
    'beginAltitude', 'endAltitude', 'status', 'callsign', ...
    'beginDate', 'endDate', 'beginLat', 'beginLon', 'endLat', 'endLon', ...
    'segmentLength', 'segmentParityColor', 'beginTimestamp', 'endTimestamp'};

columnsToKeep = [5,6,10,13,14,15,16];
flight_latlons = flight_plans(:, columnsToKeep);

% ignore incorrect negative values because it is not our area of interest
flight_latlons{:,"beginLat"} = flight_latlons{:,"beginLat"} / 60;
flight_latlons{:,"beginLon"} = flight_latlons{:,"beginLon"} / 60;
flight_latlons{:,"endLat"} = flight_latlons{:,"endLat"} / 60;
flight_latlons{:,"endLon"} = flight_latlons{:,"endLon"} / 60;

rowIndices = find(flight_latlons.beginLat > 47 & flight_latlons.beginLat < 50);
filtered_flights = flight_latlons(rowIndices, :)

rowIndices = find(filtered_flights.endLat > 47 & filtered_flights.endLat < 50);
filtered_flights = filtered_flights(rowIndices, :)

rowIndices = find(filtered_flights.beginLon > 9 & filtered_flights.beginLon < 13);
filtered_flights = filtered_flights(rowIndices, :)

rowIndices = find(filtered_flights.endLon > 9 & filtered_flights.endLon < 13);
filtered_flights = filtered_flights(rowIndices, :)

rowIndices = find(filtered_flights.beginTime > 150000 & filtered_flights.beginTime < 173000);
filtered_flights = filtered_flights(rowIndices, :)

rowIndices = find(filtered_flights.endTime > 150000 & filtered_flights.endTime < 173000);
filtered_flights = filtered_flights(rowIndices, :)

filename = fullfile('.', 'temp', 'flights_case1.csv');
writetable(filtered_flights, filename)


