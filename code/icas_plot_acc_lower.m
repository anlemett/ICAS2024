%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ICAS24: airspace capacity 
% Anastasia Lemetti
% MATLAB version: MATLAB R2024a
% 
% plot lower sector configurations for 2023-06-08
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc; clear; close all;

% Airspace configuration
lower_sector_filename = fullfile('.', 'code_input', 'airspace_data', 'Lower_airspace', ...
    'fir_nextto_EDMMCTAA_2023-06-08.json');

lower_sector = jsondecode(fileread(lower_sector_filename));

exp_date = 'x2023_06_08';

min_lon = 5;
max_lon = 19;
min_lat = 46;
max_lat = 55;

figure; hold on;

acc_struct_arr = [lower_sector.(exp_date)]
acc_arr = fieldnames([lower_sector.(exp_date)]);

main_acc = 'EDMMCTAA';
%acc_arr(strcmpi(acc_arr, main_acc)) = [];
acc_arr = {'EDMMCTAA', 'EDGGCTA4', 'EDGGCTA8', 'EDMMCTAE', 'LOVVCTA',...
    'LSAZCTA', 'LSAZUTA', 'LOVV1CTA', 'LKAAUTA'};

colors = generateDistinctColors(length(acc_arr));

confs = [lower_sector.(exp_date).(main_acc).configurations];
fields = fieldnames(confs);
main_conf = confs.(fields{1});
main_latitudes = main_conf.polygon_config(:,1);
main_longitudes = main_conf.polygon_config(:,2);

for i = 1:numel(acc_arr)
    %figure; hold on;
    struct_acc = acc_arr{i};
    
    acc = char(struct_acc);
    confs = [lower_sector.(exp_date).(acc).configurations];

    fields = fieldnames(confs);

    two_acc_arr = {main_acc, acc};

    % Loop over the fields
    %for ii = 1:numel(fields)

        %conf = confs.(fields{ii});
        conf = confs.(fields{1});

        latlim = [min_lat max_lat];
        lonlim = [min_lon max_lon];
        xlim(lonlim), ylim(latlim);
        daspect([1 cos(mean(latlim)*pi/180) 1]);
        xlabel('Longitude [º]');
        ylabel('Latitude [º]');

        %fig = plot(main_longitudes, main_latitudes, 'linewidth', 2);

        latitudes = conf.polygon_config(:,1);
        longitudes = conf.polygon_config(:,2);
        fig = plot(longitudes, latitudes, 'Color', colors(i, :), 'linewidth', 2);

        legend(acc_arr, 'Position', [0.0 0.0 0.2 0.4]);
        %legend(two_acc_arr, 'Position', [0.0 0.0 0.2 0.2]);

        %filename = strcat(strcat(acc, '_'), string(i));
        filename = "lower_sector";
        saveas(fig, fullfile('.', 'figures', 'conf', filename), 'png');
        %clf(fig)
    %end
end

close all;

function colors = generateDistinctColors(n)
    % Generate n distinct colors
    colors = zeros(n, 3);
    for i = 1:n
        colors(i, :) = hsv2rgb([i/n, 1, 1]);
    end
end