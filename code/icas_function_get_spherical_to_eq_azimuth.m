%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ICAS24: airspace capacity 
% Anastasia Lemetti
% MATLAB version: MATLAB R2024a
% 
% Transform a point (lat,lon) in Geographic coordinate system
% to the point (x,y) in Spherical coordinate system
% (azimuth and elevation coordinates)
% lat_c, lon_c - centroid point of ACC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [x,y] = function_get_spherical_to_eq_azimuth(lat, lon, lat_c, lon_c)

% x axis points north and y points east

R_E = 6371000 * pi ;

phi1    = lat_c*pi/180;
lambda0 = lon_c*pi/180;

phi     = lat*pi/180;
lambda  = lon*pi/180;

cos_rho  = sin(phi1)*sin(phi) + cos(phi1)*cos(phi).*cos(lambda - lambda0);
sin_rho  = sqrt(1-cos_rho.^2);
rho      = acos(cos_rho);

k = rho./sin_rho;

y_a = k.*cos(phi).*sin(lambda - lambda0);
x_a = k.*(cos(phi1)*sin(phi) - sin(phi1)*cos(phi).*cos(lambda-lambda0));

x = R_E/pi*x_a;
y = R_E/pi*y_a;


x((lat == lat_c)&(lon == lon_c)) = 0;
y((lat == lat_c)&(lon == lon_c)) = 0;

end