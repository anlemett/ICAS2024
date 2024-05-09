
clear; close all; clc;

weather_file_name = fullfile('.', 'code_input', 'DLR_WCB_T_EUR_202306081456.xml');

S = readstruct(weather_file_name);

%polygons = {};

%forecastSet = S.wims_forecastSet;
%polygons{1} = S.wims_forecastSet(5).wims_ForecastSet.wims_status.wims_StatusWeatherProduct.wims_coverageArea ...
%   .wims_CoverageArea.wims_geometry.gml_Polygon.gml_exterior.gml_LinearRing.gml_posList;

f = getFieldValues(S);

function values = getFieldValues(strct)
    % Get the field names of this structure
    fields = fieldnames( strct );
    values = {};
    % Loop over the fields
    for ii = 1:numel(fields)

        array = strct.(fields{ii});
        num_el = length(array);

        if num_el>1 && isstruct(array(1))
            for jj = 1:num_el

                strct_jj = strct.(fields{ii})(jj);

                value = getFieldValues(strct_jj);
                values=[values;value];
            end
        else
            if isstruct( strct.(fields{ii}) )
                % This is a substructure, recursively fetch fields
                value = getFieldValues(strct.(fields{ii}));
                values=[values;value];
            else
                if strcmp('gml_posList', fields(ii))
                    value = getfield(strct,'gml_posList');
                    values=[values;value];
                end
            end
        end

    end
end
