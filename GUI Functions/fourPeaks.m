function [fitresult, gof] = fourPeaks(x, y, lower, start, upper)
%CREATEFIT(X,Y)
%  Create a fit.
%
%  Data for 'four peak Lorentzian' fit:
%      X Input : x
%      Y Output: y
%  Output:
%      fitresult : a fit object representing the fit.
%      gof : structure with goodness-of fit info.
%
%  See also FIT, CFIT, SFIT.

%  Auto-generated by MATLAB on 24-Jul-2017 15:32:01
%  Edited by Emma Gan on 24-Jul-2017

%% Fit: 'Four peak Lorentzian'.
[xData, yData] = prepareCurveData( x, y );

% Set up fittype and options.
ft = fittype(strcat('i2D1*FW2D1^2/(4*(x-fr2D1)^2+FW2D1^2)+ iD*FWD^2/(4*(x-frD)^2+FWD^2)',...
    '+ iG*FWG^2/(4*(x-frG)^2+FWG^2)+  iDpr*FWDpr^2/(4*(x-frDpr)^2+FWDpr^2)'),...
    'independent', 'x', 'dependent', 'y' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
% FWHM freq intensity
opts.Lower = lower;
opts.StartPoint = start;
opts.Upper = upper;

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );

%{
%Plot fit with data.
h = plot( fitresult, xData, yData );
legend('off')
% Label axes
xlabel('Raman shift (cm^{-1})')
ylabel('Intensity (counts)')
%}
