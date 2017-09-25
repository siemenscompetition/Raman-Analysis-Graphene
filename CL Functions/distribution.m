function distribution(T,numBins)
%  create histograms of each parameter
%  saves each to file

summary = table;
num = 1;
all_names = {'I2D_IG','sigma_I2D_IG','ID_IG','sigma_ID_IG','IDpr_IG',...
	'sigma_IDpr_IG','A2D_AG','sigma_A2D_AG','AD_AG','sigma_AD_AG',...
	'ADpr_AG','sigma_ADpr_AG','original_2D_freq','sigma_original_2D_freq',...
    'fitted_2D_freq','sigma_fitted_2D_freq','original_G_freq',...
    'sigma_original_G_freq','fitted_G_freq_withDpr','sigma_fitted_G_freq_withDpr',...
    'original_D_freq','sigma_original_D','fitted_D_freq','sigma_fitted_D',...
    'Dpr_freq','sigma_Dpr','twoD_FWHM','sigma_twoD_FWHM',...
    'G_FWHM_withoutDpr','sigma_G_FWHM_withoutDpr','D_FWHM',...
    'sigma_D_FWHM','Dpr_FWHM','sigma_Dpr_FWHM',...
    'Ld_AD','sigma_Ld_AD','Ld_ID','sigma_Ld_ID',...
    'La_AD','sigma_La_AD','La_ID','sigma_La_ID'};
while num < width(T)+1
    if sum(~isnan(T{:,num})) > 1
        % Probability density function automatically fitted by MATLAB
        pd = fitdist(T{:,num},'Normal');

        % Plot the data as a histogram
        figure;
        histfit(T{:,num},numBins,'normal');
        xlabel(T.Properties.VariableNames{num},'interpreter','none')
        ylabel('Count');
        figname = strcat(T.Properties.VariableNames{num},' distribution.bmp');
        saveas(gcf,figname);
        
        % Create new column in summary table
        summary(1,num*2-1:num*2) = num2cell([pd.mu pd.sigma]);
        summary.Properties.VariableNames{num} = all_names{num};
        num = num+1;
    else
        summary(1,num*2-1:num*2) = num2cell([NaN NaN]);
        summary.Properties.VariableNames{num} = all_names{num};
        num = num+1;
    end
end
writetable(summary,'summary.xlsx');
end