% Read weather data and store it as polygons

function weather_polygons = icas_function_weather_data()

%T = 11; % Number of weather sample times, 11 - for time from 15.00 to 17.30 (*2 if use 15 minutes intervals)
% TODO: read all weather data

T=10

times = {'1456', '1511', '1526', '1541', '1556', '1611', '1626', '1641', '1656', '1711', '1726'}

weather_polygons = cell(T, 1);

%sample_time = 0; % Time of the sample from 15.00 in minutes

for t = 1:T
    
    %hour = int2str(15 + fix(sample_time/60));
    %minutes = int2str(rem(sample_time, 60));  
    %minutes = pad(minutes,2,'left','0');
    %file_name = ['./code_input/case1/real_meteo_data/2018_06_12_', hour, '_', minutes, '_135NM_cth.geojson'];

    day = 'DLR_WCB_T_EUR_20230608';
    daytime = strcat(day, times{t})
    filename = strcat(daytime, '.xml')

    weather_filename = fullfile('.', 'code_input', 'meteo_data', filename);

    S = readstruct(weather_filename);
    
    polygons_list = getWeatherPolygons(S); % 85x1 string

    num_poly = length(polygons_list); % Number of polygons
    weather_polygons{t,1} = cell(1, num_poly);
        
    for i = 1:num_poly

        lat_lon = str2num(polygons_list(i));

        lat = lat_lon(1:2:end)
        lon = lat_lon(2:2:end)

        hazard.pgon = polyshape(lon, lat);
        hazard.CTH = 0; % TODO: what to use instead of CTH (Cloud Top Height)
        weather_polygons{t,1}{i} = hazard;
    end
    
    %sample_time = sample_time + 15; 
end

end

function polygons = getWeatherPolygons(strct)
    % Get the field names of this structure
    fields = fieldnames( strct );

    if length(fields)==1
        if strcmp('wims_StatusWeatherProduct', fields{1})
            polygons = [];
            return
        end
    end

    polygons = {};
    % Loop over the fields
    for ii = 1:numel(fields)

        array = strct.(fields{ii});
        num_el = length(array);

        if num_el>1 && isstruct(array(1))
            for jj = 1:num_el

                strct_jj = strct.(fields{ii})(jj);

                polygon = getWeatherPolygons(strct_jj);
                polygons=[polygons; polygon];
            end
        else
            if isstruct( strct.(fields{ii}) )
                % This is a substructure, recursively fetch fields
                polygon = getWeatherPolygons(strct.(fields{ii}));
                polygons = [polygons; polygon];
            else
                if strcmp('gml_posList', fields(ii))
                    polygon = getfield(strct,'gml_posList');
                    polygons = [polygons; polygon];
                end
            end
        end

    end
end
