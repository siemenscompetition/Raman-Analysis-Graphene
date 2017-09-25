function parameters = plotSpectrum(x,y,coordinate,manual_GDpr,...
    lower_limits,start_points,upper_limits,lower_limits2,start_points2,upper_limits2,w)
%  Plot individual Raman spectra using cftool and save the coordinate's
%  parameters to an array.
%% Set the lower, start, and upper limits of the curve fitting.
switch manual_GDpr
    case 0
        % Automatically determined
        % Order: FWHM, freq, intensity of 2D, D, Dpr, G
        LL1 = [20 20 0 10 2670 1320 1610 1500 100 max(y)*8/9 0 400];
        SP1 = [30 30 0 15 2690 1350 1620 1590 300 max(y)*9/10 max(y)/5 500];
        UL1 = [110 50 30 50 2710 1370 1630 1700 max(y) max(y) max(y)/3 max(y)];
        % No D' peak
        LL2 = [20 0 0 10 2670 1320 1610 1500 100 max(y)*8/9 0 400];
        SP2 = [30 30 0 15 2690 1350 1620 1590 300 max(y)*9/10 0 500];
        UL2 = [110 50 0 50 2710 1370 1630 1700 max(y) max(y) max(y)/3 max(y)];
    case 1
        LL1 = lower_limits;
        SP1 = start_points;
        UL1 = upper_limits;
        
        LL2 = lower_limits2;
        SP2 = start_points2;
        UL2 = upper_limits2;
end

%% Fit the spectrum.
if max(y) < 100
    figure;
    scatter(x,y,3,'b','filled'); % plot original
    title(coordinate); box on;
    saveas(gcf,strcat(coordinate,'.bmp'));
    
    parameters = NaN(1,21);
    return
else
[fit4, gof4] = fourPeaks(x,y,LL1,SP1,UL1); %fit with 4 Lorentzian peaks
[fit3, gof3] = fourPeaks(x,y,LL2,SP2,UL2); %fit with 4 Lorentzian peaks
% If the intensity of the D' peak is very small (<1), assume it does
% not exist.
if fit4.iDpr < 1, Dpr = [0 0 NaN 0 NaN];
else
Dpr = [fit4.iDpr (fit4.iDpr*pi*fit4.FWDpr)/2 fit4.frDpr fit4.FWDpr fit4.frDpr-1620];
end

figure;
scatter(x,y,3,'b','filled'); % plot original
title(coordinate);
xlabel('Raman shift (cm^{-1})');
ylabel('Intensity (counts)');
freqs = NaN(1,7); FWHMs = NaN(1,4); [intensities, areas] = deal(NaN(1,3)); 

% If the adjusted R2 value > 0.97, keep the fit
if gof4.adjrsquare > 0.97
    hold on
    f2D = lorentz(fit4.i2D,fit4.FW2D,fit4.fr2D,x);
    fG = lorentz(fit4.iG,fit4.FWG,fit4.frG,x);
    fD = lorentz(fit4.iD,fit4.FWD,fit4.frD,x);
    fDpr = lorentz(Dpr(1),Dpr(4),Dpr(3),x);
    plot(x,fD,'g',x,fG,'g',x,f2D,'g');
    
    f = fD + fG + f2D;
    if ~isnan(Dpr(3))
        plot(x,fDpr,'g');
        f = f + fDpr;
    end
    plot(x,f,'r','Linewidth',1.3);
    
    %intensity freq offset
    original_G = peakAnalysis(x,y,'G');
    original_2D = peakAnalysis(x,y,'2D');
    original_D = peakAnalysis(x,y,'D');
    
% This is for the summary display on the image. Order: intensity area frequency FWHM offset
% There is an issue if the D peak is absent, since the code will plot it as
% if it exists.
    twoD = [original_2D(1) (fit4.i2D*pi*fit4.FW2D)/2  original_2D(2)  fit4.FW2D  original_2D(3)];
    G = [original_G(1)  (fit4.iG*pi*fit4.FWG)/2  original_G(2)  fit4.FWG  original_G(3)];
    if fit4.iD < 1, D = [0 0 NaN 0 NaN];
    else, D = [original_D(1) (fit4.iD*pi*fit4.FWD)/2  original_D(2)  fit4.FWD  original_D(3)]; end
    
    str = {horzcat('Peak      Intensity       Area       Frequency    FWHM      Offset');...
           horzcat('2D    ',sprintf('     %#0.6g',twoD ));...
           horzcat('G      ',sprintf('     %#0.6g',G ));...
           horzcat('D      ',sprintf('     %#0.6g',D ));...
           horzcat('D''     ',sprintf('     %#0.6g',Dpr ));...
           horzcat('R^2 = ',num2str(gof4.adjrsquare)) };
    annotation('textbox',[0.15 0.5 0.8 0.4],'String',str,'FitBoxToText','on');
    
    legend('off');
    
    % intensity order: I2D/IG ID/IG ID'/IG
	intensities = [twoD(1)/G(1) D(1)/G(1) Dpr(1)/G(1)];
	% area order: A2D/AG AD/AG AD'/AG
	areas = [twoD(1)/G(1) D(1)/G(1) Dpr(1)/G(1)];
	% freq order: original, fitted for 2D, G, D, D' (D' has no original)
    % for fitted G, freq is for G+D'
    freqs = [original_2D(2) twoD(3) original_G(2) fit3.frG original_D(2) fit4.frD Dpr(3)];
    % FWHM order: 2D, G(without D'), D, Dpr
    FWHMs = [twoD(4) fit4.FWG fit4.FWD Dpr(4)];
end
box on; axis tight;
saveas(gcf,strcat(coordinate,'.bmp'));

%% After plotting Raman spectrum, save parameters to an array
% In separate function makeTable, create a table from these arrays, one array
% per coordinate.

La_AD = 2.4*10^(-10)*(w^4)./areas(2); %crystalline size in nm
Ld_AD = sqrt( 1.8*10^(-9)*(w^4)./areas(2) ); %interdefect distance in nm
La_ID = 2.4*10^(-10)*(w^4)./intensities(2); %crystalline size in nm
Ld_ID = sqrt( 1.8*10^(-9)*(w^4)./intensities(2) ); %interdefect distance in nm

%order: 2D, D, D' intensities, areas, 2D, G, D, D' freq (G), FWHMs (G,Dpr), Ld_AD,
%Ld_ID, La_AD, La_ID
parameters = [ intensities areas freqs FWHMs Ld_AD Ld_ID La_AD La_ID ];
end
end

function y = lorentz(intensity,FWHM,freq,x)
y = intensity*FWHM^2 ./ (4*(x-freq).^2 + FWHM^2);
end