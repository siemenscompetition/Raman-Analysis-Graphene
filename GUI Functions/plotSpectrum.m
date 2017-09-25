function [R2,tableparam,spectrum,parameters] = plotSpectrum(x,y,coordinate,manual_GDpr,manual_2D,fig)
%  Plot individual Raman spectra using cftool and save the coordinate's
%  parameters to an array.
% no_Dpr = logical: 1 = no D' peak, 0 = D' peak
% multi_Lorentzian = logical: 1 = 2 peaks in 2D band, 0 = 1 peak in 2D band

w = 532; %excitation laser wavelength in nm (2.33 = laser energy in eV)
[twoD,G,D,Dpr] = deal(NaN(1,5));
twoD_width = 50;
%% Set the lower, start, and upper limits of the curve fitting.
switch manual_GDpr
    case 0
        % Automatically determined
        % Order: FWHM, freq, intensity of 2D, D, Dpr, G
        LL = [20 0 0 10 2500 1200 1600 1500 10 0 0 10];
        SP = [50 50 40 50 2690 1350 1610 1590 max(y)/2 max(y)/2 max(y)/8 max(y)/2];
        UL = [300 300 100 300 2800 1500 1660 1700 max(y) max(y) max(y) max(y)];
    case 1
        % No D' peak
        LL = [20 0 0 10 2500 1200 1600 1500 50 0 0 20];
        SP = [50 50 0 50 2690 1350 1610 1590 max(y)/2 max(y)/2 0 max(y)/2];
        UL = [300 300 100 0 2800 1500 1660 1700 max(y) max(y) 0 max(y)];
    case 2
        LL = lower_limits;
        SP = start_points;
        UL = upper_limits;
end

%% Fit the spectrum.
[fitt, gof] = fourPeaks(x,y,LL,SP,UL); %fit with 4 Lorentzian peaks
% If the intensity of the D' peak is very small (<1), assume it does
% not exist.
if fitt.iDpr < 1, Dpr = [0 0 NaN 0 NaN];
else
Dpr = [fitt.iDpr (fitt.iDpr*pi*fitt.FWDpr)/2 fitt.frDpr fitt.FWDpr fitt.frDpr-1620];
end

original2Dfit = [fitt.i2D1 (fitt.i2D1*pi*fitt.FW2D1)/2 fitt.fr2D1 fitt.FW2D1 fitt.fr2D1-2690];
switch manual_2D
    case 0
        % Default settings may need to change
        twoD_LL = [20 20 2500 2600 40 40];
        twoD_SP = [50 60 2680 2700 6000 8000];
        twoD_UL = [300 300 2790 2800 8000 8000];
        
        if fitt.FW2D1 > twoD_width %set as user-defined parameter
            peak = x>2550 & x<2800;
            [fitRes, gof2D] = twoPeaks(x(peak),y(peak),twoD_LL,twoD_SP,twoD_UL,0);
            twoD1 = [fitRes.i2D1 (fitRes.i2D1*pi*fitRes.FW2D1)/2 fitRes.fr2D1 fitRes.FW2D1 fitRes.fr2D1-2690];
            twoD2 = [fitRes.i2D2 (fitRes.i2D2*pi*fitRes.FW2D2)/2 fitRes.fr2D2 fitRes.FW2D2 fitRes.fr2D2-2690];
            multi_Lorentzian = 1;
        else
            twoD1 = original2Dfit;
            twoD2 = [NaN NaN NaN NaN NaN];
            multi_Lorentzian = 0;
        end
    case 1
        twoD1 = original2Dfit;
        twoD2 = [NaN NaN NaN NaN NaN];
        multi_Lorentzian = 0;
    case 2
        % Default settings may need to change
        twoD_LL = twoD_lower;
        twoD_SP = twoD_start;
        twoD_UL = twoD_upper;
        
        peak = x>2550 & x<2800;
        [fitRes, gof2D] = twoPeaks(x(peak),y(peak),twoD_LL,twoD_SP,twoD_UL,0);
        twoD1 = [fitRes.i2D1 (fitRes.i2D1*pi*fitRes.FW2D1)/2 fitRes.fr2D1 fitRes.FW2D1 fitRes.fr2D1-2690];
        twoD2 = [fitRes.i2D2 (fitRes.i2D2*pi*fitRes.FW2D2)/2 fitRes.fr2D2 fitRes.FW2D2 fitRes.fr2D2-2690];
        multi_Lorentzian = 1;
end

%figure;
spectrum = axes('Parent',fig);
scatter(x,y,3,'b','filled'); % plot original
xlabel('Raman shift (cm^{-1})');
ylabel('Intensity (counts)');
[intensities,freqs,offsets] = deal(NaN(1,8));
[areas,FWHMs] = deal(NaN(1,5)); intRatio = NaN(1,4); areaRatio = NaN(1,3);
tableparam = NaN(4,5); R2 = NaN;

% If the adjusted R2 value > 0.8, keep the fit
if gof.adjrsquare > 0.95
    hold on; R2 = gof.adjrsquare;
    f2D1 = lorentz(twoD1(1),twoD1(4),twoD1(3),x);
    f2D2 = lorentz(twoD2(1),twoD2(4),twoD2(3),x);
    fG = lorentz(fitt.iG,fitt.FWG,fitt.frG,x);
    fD = lorentz(fitt.iD,fitt.FWD,fitt.frD,x);
    fDpr = lorentz(Dpr(1),Dpr(4),Dpr(3),x);
    plot(x,fD,'g',x,fG,'g',x,f2D1,'g');
    
    f = fD + fG + f2D1;
    if ~isnan(Dpr(3))
        plot(x,fDpr,'g');
        f = f + fDpr;
    end
    if multi_Lorentzian
        plot(x,f2D2,'g');
        f = f + f2D2;
    end
    plot(x,f,'r','Linewidth',1.3);
    
    %intensity freq offset
    original_G = peakAnalysis(x,y,'G');
    original_2D = peakAnalysis(x,y,'2D');
    original_D = peakAnalysis(x,y,'D');
    
% This is for the summary display on the image. Order: intensity area frequency FWHM offset
% There is an issue if the D peak is absent, since the code will plot it as
% if it exists.
    twoD = [original_2D(1) original2Dfit(2)  original_2D(2)  original2Dfit(4)  original_2D(3)];
    G = [original_G(1)  (fitt.iG*pi*fitt.FWG)/2  original_G(2)  fitt.FWG  original_G(3)];
    if fitt.iD < 1, D = [0 0 NaN 0 NaN];
    else, D = [original_D(1) (fitt.iD*pi*fitt.FWD)/2  original_D(2)  fitt.FWD  original_D(3)]; end
    
%     must fix 2D display: if there are two Lorentzians within the 2D peak,
%     the FWHM and area of a single peak, the first one, will be displayed.
%     Change it to display the parameters for the entire 2D peak.
%     str = {horzcat('Peak      Intensity       Area         Frequency      FWHM        Offset');...
%            horzcat('2D    ',sprintf('     %#0.7g',twoD ));...
%            horzcat('G      ',sprintf('     %#0.7g',G ));...
%            horzcat('D      ',sprintf('     %#0.7g',D ));...
%            horzcat('D''     ',sprintf('     %#0.7g',Dpr ));...
%            horzcat('R^2 = ',num2str(gof.adjrsquare)) };
%     annotation('textbox',[0.15 0.5 0.8 0.4],'String',str,'FitBoxToText','on');
    
    legend('off');
    tableparam = [D(1:5); G(1:5); twoD(1:5); Dpr(1:5)];
    
    % intensity order: original2D, fitted2D1, fitted2D2, originalG, fitted G,
    % originalD, fittedD, fittedDpr
    intensities = [original_2D(1) twoD1(1) twoD2(1)...
        original_G(1) fitt.iG original_D(1) fitt.iD Dpr(1)];
    % area order: 2D1, 2D2, G, D, Dpr
    areas = [twoD1(2) twoD2(2) (fitt.iG*pi*fitt.FWG)/2 (fitt.iD*pi*fitt.FWD)/2 Dpr(2)];
    % frequency order: original2D, fitted2D1, fitted2D2, originalG, fitted G,
    % originalD, fittedD, fittedDpr
    freqs = [original_2D(2) twoD1(3) twoD2(3)...
        original_G(2) fitt.frG original_D(2) fitt.frD Dpr(3)];
    % FWHM order: 2D1, 2D2, G, D, Dpr
    FWHMs = [twoD1(4) twoD2(4) fitt.FWG fitt.FWD Dpr(4)];
    % offset order: original2D, fitted2D1, fitted2D2, originalG, fitted G,
    % originalD, fittedD, fittedDpr
    offsets = [original_2D(3) twoD1(5) twoD2(5) ...
        original_G(3) fitt.frG-1580 original_D(3) fitt.frD-1350 Dpr(5)];
    %I2D/IG, ID/IG, IDpr/IG, ID/IDpr
    intRatio = [ twoD(1)/G(1) D(1)/G(1) Dpr(1)/G(1) D(1)/Dpr(1)];
    %A2D/AG, AD/AG, ADpr/AG, AD/ADpr
    areaRatio = [ twoD(2)/G(2) D(2)/G(2) Dpr(2)/G(2)];
end
%saveas(gcf,strcat(coordinate,'.bmp'));

%% After plotting Raman spectrum, save parameters to an array
% In separate function makeTable, create a table from these arrays, one array
% per coordinate.

L_a = 2.4*10^(-10)*(w^4)./areaRatio(2); %crystalline size in nm
n_d = 1.8*10^22/(w^4).*areaRatio(2); %defect density in cm^-2
L_d = sqrt( 1.8*10^(-9)*(w^4)./areaRatio(2) ); %interdefect distance in nm

%order: 2D, G, D, D' intensity, area, freq, FWHM, offsets etc.
parameters = [ intensities areas freqs FWHMs offsets intRatio...
    areaRatio L_a n_d L_d ];

end

function y = lorentz(intensity,FWHM,freq,x)
y = intensity*FWHM^2 ./ (4*(x-freq).^2 + FWHM^2);
end