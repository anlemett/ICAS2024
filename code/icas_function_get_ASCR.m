%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ICAS24: airspace capacity 
% Anastasia Lemetti
% MATLAB version: MATLAB R2024a
% 
% returns ASCR for the given altitude band (altitudes between flight levels)
% and weather polygons for all flows with weights
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ASCR= icas_function_get_ASCR(a_band, weather_polygons, flows, W)

% Compute ASCR (Available Sector (ACC) Capacity Ratio) of ACC

AFCR = zeros(1,2);

for i=1:2

    %AFCR(i) = function_get_AFCR(a_band, weather_polygons, flows(i));

    %temporary:
    AFCR(i) = 0.25;
end

ASCR = AFCR(1)*W(1,1) + AFCR(1)*W(1,2) + AFCR(2)*W(2,1) + AFCR(1)*W(2,2);

end