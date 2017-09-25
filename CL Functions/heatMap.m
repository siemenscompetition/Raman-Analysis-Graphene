function heatMap(xPos,T,plot_white)
%  maps a color image of parameter values at (xPos,yPos)

yInd = find( xPos(1:end-1)~=xPos(2:end),1 );
xInd = length(xPos)/yInd;
[ ID_IG, I2D_IG, AD_AG, FWHM_D, FWHM_2D, FWHM_G, La_AD, La_ID, Ld_AD, Ld_ID ] ...
    = deal(zeros(yInd,xInd));

for n = 1: xInd
    ID_IG(1:yInd,n) = T.ID_IG( 1+(n-1)*yInd:n*yInd );
    I2D_IG(1:yInd,n) = T.I2D_IG( 1+(n-1)*yInd:n*yInd );
    AD_AG(1:yInd,n) = T.AD_AG( 1+(n-1)*yInd:n*yInd );
    FWHM_D(1:yInd,n) = T.D_FWHM( 1+(n-1)*yInd:n*yInd );
    FWHM_2D(1:yInd,n) = T.twoD_FWHM( 1+(n-1)*yInd:n*yInd );
    FWHM_G(1:yInd,n) = T.G_FWHM_withoutDpr( 1+(n-1)*yInd:n*yInd );
    La_AD(1:yInd,n) = T.La_AD( 1+(n-1)*yInd:n*yInd );
    La_ID(1:yInd,n) = T.La_ID( 1+(n-1)*yInd:n*yInd );
    Ld_AD(1:yInd,n) = T.Ld_AD( 1+(n-1)*yInd:n*yInd );
    Ld_ID(1:yInd,n) = T.Ld_ID( 1+(n-1)*yInd:n*yInd );
end

if plot_white
    ID_IG = [ID_IG nan(yInd,1); nan(1,xInd+1)];
    I2D_IG = [I2D_IG nan(yInd,1); nan(1,xInd+1)];
    AD_AG = [AD_AG nan(yInd,1); nan(1,xInd+1)];
    FWHM_D = [FWHM_D nan(yInd,1); nan(1,xInd+1)];
    FWHM_2D = [FWHM_2D nan(yInd,1); nan(1,xInd+1)];
    FWHM_G = [FWHM_G nan(yInd,1); nan(1,xInd+1)];
    La_AD = [La_AD nan(yInd,1); nan(1,xInd+1)];
    La_ID = [La_ID nan(yInd,1); nan(1,xInd+1)];
    Ld_AD = [Ld_AD nan(yInd,1); nan(1,xInd+1)];
    Ld_ID = [Ld_ID nan(yInd,1); nan(1,xInd+1)];
end

saveName = {'I(D)_I(G)', 'I(2D)_I(G)', 'A(D)_A(G)', ...
            'FWHM-D', 'FWHM-2D', 'FWHM-G', 'La_AD', ...
            'La_ID', 'Ld_AD', 'Ld_ID'};
list = [{ID_IG}, {I2D_IG}, {AD_AG}, {FWHM_D}, {FWHM_2D}, ...
        {FWHM_G}, {La_AD}, {La_ID}, {Ld_AD}, {Ld_ID}];

for n = 1:length(list)
    figure
    if plot_white, pcolor(list{n}); shading flat;
	else imagesc(list{n}); end
    colormap(autumn)
    colorbar
    title(strcat(saveName{n},' map'),'interpreter','none')
    xlabel('X')
    ylabel('Y')
    saveas(gcf,strcat(saveName{n},' map.bmp'))
end

end