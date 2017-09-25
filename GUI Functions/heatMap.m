function results = heatMap(xPos,T,plot_white)
%  maps a color image of parameter values at (xPos,yPos)

yInd = find( xPos(1:end-1)~=xPos(2:end),1 );
xInd = length(xPos)/yInd;
[ ID_IG, I2D_IG, AD_AG, A2D_AG, FWHM_D, FWHM_2D1, ...
    FWHM_G, L_a, n_d, L_d ] = deal(zeros(yInd,xInd));

for n = 1: xInd
    ID_IG(1:yInd,n) = T.ID_IG( 1+(n-1)*yInd:n*yInd );
    I2D_IG(1:yInd,n) = T.I2D_IG( 1+(n-1)*yInd:n*yInd );
    AD_AG(1:yInd,n) = T.AD_AG( 1+(n-1)*yInd:n*yInd );
    A2D_AG(1:yInd,n) = T.A2D_AG( 1+(n-1)*yInd:n*yInd );
    FWHM_D(1:yInd,n) = T.D_FWHM( 1+(n-1)*yInd:n*yInd );
    FWHM_2D1(1:yInd,n) = T.twoD1_FWHM( 1+(n-1)*yInd:n*yInd );
    FWHM_G(1:yInd,n) = T.G_FWHM( 1+(n-1)*yInd:n*yInd );
    L_a(1:yInd,n) = T.L_a( 1+(n-1)*yInd:n*yInd );
    n_d(1:yInd,n) = T.n_d( 1+(n-1)*yInd:n*yInd );
    L_d(1:yInd,n) = T.L_d( 1+(n-1)*yInd:n*yInd );
end
if plot_white
ID_IG = [ID_IG nan(yInd,1); nan(1,xInd+1)];
I2D_IG = [I2D_IG nan(yInd,1); nan(1,xInd+1)];
AD_AG = [AD_AG nan(yInd,1); nan(1,xInd+1)];
A2D_AG = [A2D_AG nan(yInd,1); nan(1,xInd+1)];
FWHM_D = [FWHM_D nan(yInd,1); nan(1,xInd+1)];
FWHM_2D1 = [FWHM_2D1 nan(yInd,1); nan(1,xInd+1)];
FWHM_G = [FWHM_G nan(yInd,1); nan(1,xInd+1)];
L_a = [L_a nan(yInd,1); nan(1,xInd+1)];
n_d = [n_d nan(yInd,1); nan(1,xInd+1)];
L_d = [L_d nan(yInd,1); nan(1,xInd+1)];
end

list = [{I2D_IG}, {ID_IG}, {A2D_AG}, {AD_AG}, {FWHM_2D1}, {FWHM_G}, ...
        {FWHM_D}, {L_a}, {n_d}, {L_d}];

results = [{list} {xInd} {yInd}];
%{
if plot_FWHM2D2
    saveName = {'I(D)_I(G)', 'I(2D)_I(G)', 'A(D)_A(G)', 'A(2D)_A(G)', ...
            'FWHM-D', 'FWHM-2D1', 'FWHM-2D2', 'FWHM-G', 'L_a', 'n_d', 'L_d'};
    list = [{ID_IG}, {I2D_IG}, {AD_AG}, {A2D_AG}, {FWHM_D}, {FWHM_2D1}, ...
        {FWHM_2D2}, {FWHM_G}, {L_a}, {n_d}, {L_d}];
else
    saveName = {'I(D)_I(G)', 'I(2D)_I(G)', 'A(D)_A(G)', 'A(2D)_A(G)', ...
            'FWHM-D', 'FWHM-2D1', 'FWHM-G', 'L_a', 'n_d', 'L_d'};
    list = [{ID_IG}, {I2D_IG}, {AD_AG}, {A2D_AG}, {FWHM_D}, {FWHM_2D1}, ...
        {FWHM_G}, {L_a}, {n_d}, {L_d}];
end
% add CLim
for n = 1:length(list)
    figure
    pcolor(list{n})
    shading flat;
    colormap(autumn)
    colorbar
    title(strcat(saveName{n},' map'))
    xlabel('X')
    ylabel('Y')
    saveas(gcf,strcat(saveName{n},' map.bmp'))
end
%}
end