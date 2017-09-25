function [T,spec,tableparam,R2] = makeTable(x,y,xPos,yPos,...
	manual_GDpr,manual_2D,fig)
%  Run through all coordinates to plot spectra

T = table;

for ii = 1:length(xPos)
    coordinate = strcat('(',num2str(xPos(ii)),',',num2str(yPos(ii)),')');
    %disp(ii);
    % Restrict range of Raman spectrum from 700 to 3000 cm^-1.
    x1 = x; y1 = y(:,ii);
    if x1(1) < 1100, y1(x1<1100) = []; x1(x1<1100) = []; end
    if x1(end) > 3000, y1(x1>3000) = []; x1(x1>3000) = []; end
    
    % Plot spectrum and create row in table.
    [rsquared,tp,sp,parameters] = plotSpectrum(x1,y1,...
		coordinate,manual_GDpr,manual_2D,fig);
    R2(ii) = rsquared;
    tableparam{1,ii} = tp;
    spec(ii) = sp;
    T(ii,:) = num2cell(parameters);
    T.Properties.RowNames{ii} = coordinate;
    %h =  findobj('type','figure');
    %if length(h) > 10, close all; end
end

T.Properties.VariableNames = {'original_2D_int','fitted_2D1_int','fitted_2D2_int',...
    'original_G_int','fitted_G_int','original_D_int','fitted_D_int','Dpr_int',...
	'twoD1_area','twoD2_area','G_area','D_area','Dpr_area','original_2D_freq',...
    'fitted_2D1_freq','fitted_2D2_freq','original_G_freq','fitted_G_freq',...
    'original_D_freq','fitted_D_freq','Dpr_freq','twoD1_FWHM','twoD2_FWHM',...
    'G_FWHM','D_FWHM','Dpr_FWHM','original_2D_offset','fitted_2D1_offset',...
	'fitted_2D2_offset','original_G_offset','fitted_G_offset','original_D_offset',...
    'fitted_D_offset','Dpr_offset',...
    'I2D_IG','ID_IG','IDpr_IG','ID_IDpr','A2D_AG','AD_AG','ADpr_AG',...
    'L_a','n_d','L_d'};

T = standardizeMissing(T,Inf);
%writetable(T,'table.xlsx','WriteRowNames',true);
end