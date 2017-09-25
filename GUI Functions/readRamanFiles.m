function finalMap = readRamanFiles(ramanMap)
%  read Raman map, save to data.mat
%  each file has rows of [ wavenumber, intensity ]

data = importdata(ramanMap);
map = data';
[r,c] = size(map); %dimensions of map

%  assign variables
x(1:(r-2),1) = map(3:r,1); %wavenumber or Raman shift
xPos(1:c-1,1) = map(1,2:c); %x coordinate
yPos(1:c-1,1) = map(2,2:c); %y coordinate
y(1:(r-2),1:c-1) = map(3:r,2:c); %intensities

% noise smoothing here? replace the y values between regions with double
% deriv/diff(diff) greater than threshold with NaN values

finalMap = [{x}, {y}, {xPos}, {yPos}];

end