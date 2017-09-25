function T = makeTable(x,y,xPos,yPos,manual_GDpr,...
    lower_limits,start_points,upper_limits,...
    lower_limits2,start_points2,upper_limits2,...
    lower_range,upper_range,w)
%  Run through all coordinates to plot spectra

T = table;

for ii = 1:length(xPos)
    coordinate = strcat('(',num2str(xPos(ii)),',',num2str(yPos(ii)),')');
    %disp(ii);
    % Restrict range of Raman spectrum from 1000 to 3000 cm^-1.
    x1 = x; y1 = y(:,ii);
    if x1(1) < lower_range, y1(x1<lower_range) = []; x1(x1<lower_range) = []; end
    if x1(end) > upper_range, y1(x1>upper_range) = []; x1(x1>upper_range) = []; end
    
    % Plot spectrum and create row in table.
    parameters = plotSpectrum(x1,y1,coordinate,manual_GDpr,...
        lower_limits,start_points,upper_limits,...
        lower_limits2,start_points2,upper_limits2,w);
    
    T(ii,:) = num2cell(parameters);
    T.Properties.RowNames{ii} = coordinate;
    h =  findobj('type','figure');
    if length(h) > 10, close all; end
end

T.Properties.VariableNames = {'I2D_IG','ID_IG','IDpr_IG',...
	'A2D_AG','AD_AG','ADpr_AG','original_2D_freq',...
    'fitted_2D_freq','original_G_freq','fitted_G_freq_withDpr',...
    'original_D_freq','fitted_D_freq','Dpr_freq','twoD_FWHM',...
    'G_FWHM_withoutDpr','D_FWHM','Dpr_FWHM',...
    'Ld_AD','Ld_ID','La_AD','La_ID'};

T = standardizeMissing(T,Inf);
writetable(T,'table.xlsx','WriteRowNames',true);
end