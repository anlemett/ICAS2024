function [sector_names, sector_time, sector_data] = icas_function_all_configurations(config_vec, sector_filename)

config_list = unique(config_vec);
nc = numel(config_list); % number of different configurations

sector_data_aux  = cell(1,nc);
sector_names_aux = cell(1,nc);
for i = 1:nc
    config_name = config_list{i};
    [sector_data_aux{i}, sector_names_aux{i}] = icas_function_sector_config(config_name, sector_filename);
end

all_names = horzcat(sector_names_aux{:});
[sector_names, index] = unique(all_names, 'stable');

all_sectors = horzcat(sector_data_aux{:});
sector_data = all_sectors(index);

sector_time = false(numel(config_vec), numel(sector_names));

for i = 1:nc
    index_rows = strcmp(config_list{i}, config_vec);
    index_cols = false(size(sector_names));
    for j = 1:numel(sector_names_aux{i})
        index_cols = index_cols|strcmp(sector_names, sector_names_aux{i}(j));
    end
    sector_time(index_rows, index_cols) = true;
end

end