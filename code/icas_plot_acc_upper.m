%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ICAS24: airspace capacity 
% Anastasia Lemetti
% MATLAB version: MATLAB R2023b
% 
% plot lower sector configurations for 2023-06-08

clc; clear; close all;

% Airspace configuration
upper_sector_filename = fullfile('.', 'code_input', 'airspace_data', 'Upper_airspace', 'fir_EDUU_2023-06-08.json');

upper_sector = jsondecode(fileread(upper_sector_filename));

exp_date = 'x2023_06_08';
acc_arr = {'EDUUUTAC', 'EDUUUTAE', 'EDUUUTAS', 'EDUUUTAW'}

min_lon = 5;
max_lon = 16;
min_lat = 46;
max_lat = 55;

figure; hold on;

for struct_acc = acc_arr
    
    acc = char(struct_acc);
    confs = [upper_sector.(exp_date).(acc).configurations];

    fields = fieldnames(confs);

    % Loop over the fields
    %for ii = 1:numel(fields)

        %conf = confs.(fields{ii});
        conf = confs.(fields{1});

        latlim = [min_lat max_lat];
        lonlim = [min_lon max_lon];
        xlim(lonlim), ylim(latlim);
        daspect([1 cos(mean(latlim)*pi/180) 1]);
        xlabel('Longitude [º]')
        ylabel('Latitude [º]')

        latitudes = conf.polygon_config(:,1)
        longitudes = conf.polygon_config(:,2)
        fig = plot(longitudes, latitudes, 'linewidth', 2);

        legend(acc_arr, 'Position', [0.0 0.0 0.2 0.2])

        %filename = strcat(strcat(acc, '_'), char(fields{ii}));
        filename = "upper_sector"
        saveas(fig, fullfile('.', 'figures', 'conf', filename), 'png');
        %clf(fig)
    %end
end

