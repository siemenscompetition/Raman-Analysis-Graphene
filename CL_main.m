% This MATLAB script analyzes .txt Raman maps. The main file (CL_main) must
% be in the same directory as the .txt Raman map. Outputs within the folder
% include
%  - A folder called "spectra" containing Raman spectra at each coordinate
%  - A folder called "maps" containing heat maps of I2D/IG, ID/IG, etc.
%  - A folder called "distribution" containing the distribution of each peak
%    parameter (intensity,area,FWHM,etc.)
%  - An Excel table of peak parameters

clc;    % Clear the command window.
close all;  % Close all figures.
clear;  % Erase all existing variables.
%% Enter user-defined inputs here:
% 1 or 2 peaks for G and Dpr peak
% Number of bins for distribution
% Auto-fill noisy spectra in Raman map
% Set range of spectrum to analyze
% Heat map, distribution, table options
% Excitation laser wavelength in nm

% These values determine whether the fit will be automatically determined
% by MATLAB or overriden by the user.
%  - manual_GDpr = 0: automatically determined
%  - manual_GDpr = 1: user-defined lower limits, start points, and upper limits

manual_GDpr = 1;
numBins = 20;
plot_white = 0;
lower_spec_range = 1000;
upper_spec_range = 3000;
w = 532; % 2.33 = laser energy in eV

%% Manual fit options for lower limits, start points, and upper limits
% Remember to change manual_GDpr to 1 for these inputs to register.

% Format: FWHM-2D FWHM-D FWHM-Dpr FWHM-G
%         freq-2D freq-D freq-Dpr freq-G
%         intensity-2D intensity-D intensity-Dpr intensity-G
lower_limits = [20 0 0 10 2670 1320 1600 1500 400 0 0 400];
start_points = [30 10 0 15 2690 1350 1610 1590 200 20 0 200];
upper_limits = [60 30 10 25 2710 1370 1630 1700 2000 70 10 2000];
% No D' peak
n = 3;
lower_limits2 = lower_limits;
start_points2 = start_points;
upper_limits2 = upper_limits;
while n < length(lower_limits)
    lower_limits2(n) = 0; start_point2(n) = 0; upper_limits2(n) = 0;
    n = n+4;
end

%% Process the Raman file.
% Keep the main function in the same directory as the text file to be analyzed.
% If there is no empty folder called 'maps','spectra', or 'distribution,'
% these will be created.

curr_dir = pwd;
if ~exist(strcat(curr_dir,'\spectra'),'dir'), mkdir('spectra'); end
if ~exist(strcat(curr_dir,'\maps'),'dir'), mkdir('maps'); end
if ~exist(strcat(curr_dir,'\distributions'),'dir'), mkdir('distributions'); end

% Find and read the Raman text file.
files = dir('*.txt'); 
map = readRamanFiles(files(1).name); % create map
x = map{1,1};
y = map{1,2};
xPos = map{1,3};
yPos = map{1,4};

%% Analyze spectra and create table.
cd(strcat(curr_dir,'\spectra'));
T = makeTable(x,y,xPos,yPos,manual_GDpr,...
    lower_limits,start_points,upper_limits,...
    lower_limits2,start_points2,upper_limits2,...
    lower_spec_range,upper_spec_range,w);
close all;
movefile('table.xlsx',curr_dir);

%% Create distributions and summary tables.
cd(strcat(curr_dir,'\distributions'));
distribution(T,numBins);
close all;
movefile('summary.xlsx',curr_dir);

%% Create heat maps.
cd(strcat(curr_dir,'\maps'));
heatMap(xPos,T,plot_white)
close all;

cd(curr_dir);