function varargout = RamanAnalysis(varargin)
% RAMANANALYSIS MATLAB code for RamanAnalysis.fig
%      RAMANANALYSIS, by itself, creates a new RAMANANALYSIS or raises the existing
%      singleton*.
%
%      H = RAMANANALYSIS returns the handle to a new RAMANANALYSIS or the handle to
%      the existing singleton*.
%
%      RAMANANALYSIS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RAMANANALYSIS.M with the given input arguments.
%
%      RAMANANALYSIS('Property','Value',...) creates a new RAMANANALYSIS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before RamanAnalysis_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to RamanAnalysis_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help RamanAnalysis

% Last Modified by GUIDE v2.5 10-Sep-2017 12:45:56

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @RamanAnalysis_OpeningFcn, ...
                   'gui_OutputFcn',  @RamanAnalysis_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before RamanAnalysis is made visible.
function RamanAnalysis_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to RamanAnalysis (see VARARGIN)

%Expand to see all variables in use
%{
% handles.varargin
% handles.tableparam
% handles.spectra = copy of all spectra axes, in separate window [SAVE]
% handles.current_spec = current spectrum axes shown on panel
% handles.slide = current spectrum slider bar/value
% handles.optical = optical image axes
% handles.table = table [SAVE]
% [ handles.I2D_IG; handles.ID_IG; handles.A2D_AG; handles.AD_AG
% handles.FWHM_2D; handles.FWHM_G; handles.FWHM_D; handles.L_a
% handles.n_d; handles.L_d ] = axes of heat map buttons
% handles.maps = copy of all heat maps [SAVE]
% handles.current_map = current map shown on panel
% handles.coordinates = coordinates from file, used in spectrum titles
% handles.annotation = box showing the region that is selected
% handles.xInd = number of regions in heat map in x direction
% handles.yInd = number of regions in heat map in y direction
% handles.xCoor = current x-coordinate of pointer, rounded to upper int
% handles.yCoor = current y-coordinate of pointer, rounded to upper int
% handles.xsub
% handles.ysub
% handles.plot_white
%}
handles.plot_white = 0;
% Processing the Raman text file and image
map = readRamanFiles(varargin{1,1});
opt = imread(varargin{1,2});
% Create local variables x,y,xPos,yPos to be used as args
x = map{1,1}; y = map{1,2}; xPos = map{1,3}; yPos = map{1,4};
% Create coordinates to be displayed in title of spectra.
coordinates = strcat('(',num2str(xPos),',',num2str(yPos),')');
handles.coordinates = coordinates;
handles.varargin = varargin;
%-------------------------------------------------------------------------
% Display optical image.
axes(handles.optical)
im = imagesc(opt);
xlabel('X (µm)','FontSize',10); ylabel('Y (µm)','FontSize',10);
xlimAx = get(handles.optical,'XLim'); ylimAx = get(handles.optical,'YLim');

handles.optical.XTick = xlimAx(1): ((xlimAx(2)-xlimAx(1))/4) :xlimAx(2);
handles.optical.YTick = ylimAx(1): ((ylimAx(2)-ylimAx(1))/4) :ylimAx(2);

xcoor1 = varargin{1,4}(1);
xcoor2 = varargin{1,4}(2);
ycoor1 = varargin{1,4}(3);
ycoor2 = varargin{1,4}(4);
handles.optical.XTickLabels = xcoor1: (xcoor2-xcoor1)/4: xcoor2;
handles.optical.YTickLabels = ycoor1: (ycoor2-ycoor1)/4: ycoor2;
xlim = get(im,'XData'); ylim = get(im,'YData'); hold on
%-------------------------------------------------------------------------
% Create axes of analyzed spectra and table. Turn off visibility when
% finished, and save to handles
fig = figure('Name','Running Spectra Analysis','NextPlot','add');
[T,spec,tableparam,rsquared] = makeTable(x,y,xPos,yPos,0,0,fig);
fig.Visible = 'off';
handles.spectra = spec;
handles.table = T;
handles.tableparam = tableparam;
handles.rsquared = rsquared;
%-------------------------------------------------------------------------
% Initialize first spectrum value (slide = 1) on axes handles.current_spec.
axes(handles.current_spec)
specChild = handles.spectra(1).Children;
% Children of original axes are copied to new axes.
copyobj(specChild,handles.current_spec);
axis(handles.current_spec,'tight');
% Label the x-axis, y-axis, and title.
xlabel('Raman shift (cm^{-1})','FontSize',10);
ylabel('Intensity (counts)','FontSize',10);
title(coordinates(1,:),'FontSize',11);

% Set up table peak parameters corresponding to first spectrum.
handles.peakTable.Data = handles.tableparam{1,1};
rsq = strcat('R2 = ',num2str(handles.rsquared(1)));
set(handles.R2,'String',rsq);

% Set up slider range (min/max), current value, and slider step
set(handles.slide,'Min',1);
set(handles.slide,'Max',length(xPos));
set(handles.slide,'Value',1);
set(handles.slide,'SliderStep',[1/(length(xPos)-1),1/(length(xPos)-1)]);
%------------------------------------------------------------------------
% Create heat maps.
results = heatMap(xPos,T,handles.plot_white);
heatmaps = results{1}; xInd = results{2}; yInd = results{3};

% Create annotation on optical image.
x1 = (xlim(2)-xlim(1))*(xPos(1)+xcoor2)/(xcoor2-xcoor1) + xlim(1);
y1 = (ylim(2)-ylim(1))*(ycoor2-yPos(end))/(ycoor2-ycoor1) + ylim(1);
x2 = (xlim(2)-xlim(1))*(xPos(end)+xcoor2)/(xcoor2-xcoor1) + xlim(1);
y2 = (ylim(2)-ylim(1))*(ycoor2-yPos(1))/(ycoor2-ycoor1) + ylim(1);

intervalX = linspace(x1,x2,xInd);
intervalY = linspace(y1,y2,yInd);
[gridX,gridY] = meshgrid(intervalX,intervalY);
p = plot(gridX,gridY,'.','Color','g','Parent',handles.optical);
%--------------------------------------------------------------------------
% Make all heat map buttons ready to be pressed. Turn on HitTest and change
% NextPlot from replace to add. Change visibility of tick marks.
NameArray = {'HitTest','NextPlot','XTick','YTick'};
ValueArray = {'on','add',[],[]};
set(handles.I2D_IG, NameArray, ValueArray);
set(handles.ID_IG, NameArray, ValueArray);
set(handles.A2D_AG, NameArray, ValueArray);
set(handles.AD_AG, NameArray, ValueArray);
set(handles.FWHM_2D, NameArray, ValueArray);
set(handles.FWHM_G, NameArray, ValueArray);
set(handles.FWHM_D, NameArray, ValueArray);
set(handles.L_a, NameArray, ValueArray);
set(handles.n_d, NameArray, ValueArray);
set(handles.L_d, NameArray, ValueArray);
%--------------------------------------------------------------------------
% Initialize these axes to their respective plots. Will not be altered in
% any function, merely here as a image button.
axes(handles.I2D_IG); if handles.plot_white, pcolor(heatmaps{1}); shading flat;
else imagesc(heatmaps{1}); end; colormap(autumn); title('I(2D)/I(G)','FontSize',7);
axes(handles.ID_IG); if handles.plot_white, pcolor(heatmaps{2}); shading flat;
else imagesc(heatmaps{2}); end; colormap(autumn); title('I(D)/I(G)','FontSize',7);
axes(handles.A2D_AG); if handles.plot_white, pcolor(heatmaps{3}); shading flat;
else imagesc(heatmaps{3}); end; colormap(autumn); title('A(2D)/A(G)','FontSize',7);
axes(handles.AD_AG); if handles.plot_white, pcolor(heatmaps{4}); shading flat;
else imagesc(heatmaps{4}); end; colormap(autumn); title('A(D)/A(G)','FontSize',7);
axes(handles.FWHM_2D); if handles.plot_white, pcolor(heatmaps{5}); shading flat;
else imagesc(heatmaps{5}); end; colormap(autumn); title('FWHM-2D','FontSize',7);
axes(handles.FWHM_G);if handles.plot_white, pcolor(heatmaps{6}); shading flat;
else imagesc(heatmaps{6}); end; colormap(autumn); title('FWHM-G','FontSize',7);
axes(handles.FWHM_D); if handles.plot_white, pcolor(heatmaps{7}); shading flat;
else imagesc(heatmaps{7}); end; colormap(autumn); title('FWHM-D','FontSize',7);
axes(handles.L_a); if handles.plot_white, pcolor(heatmaps{8}); shading flat;
else imagesc(heatmaps{8}); end; colormap(autumn); title('L_a','FontSize',7);
axes(handles.n_d); if handles.plot_white, pcolor(heatmaps{9}); shading flat;
else imagesc(heatmaps{9}); end; colormap(autumn); title('n_d','FontSize',7);
axes(handles.L_d); if handles.plot_white, pcolor(heatmaps{10}); shading flat;
else imagesc(heatmaps{10}); end; colormap(autumn); title('L_d','FontSize',7);

% handles.I2D_IG.CLim = [0.6 0.8]; handles.ID_IG.CLim = [0.4 0.7];
% handles.A2D_AG.CLim = [0.8 1.2]; handles.AD_AG.CLim = [0.8 1.3];
% handles.FWHM_2D.CLim = [50 70]; handles.FWHM_G.CLim = [30 50]; 
% handles.FWHM_D.CLim = [70 100]; handles.L_a.CLim = [10 20];
% handles.n_d.CLim = [2e11 4e11]; handles.L_d.CLim = [8 12];
%--------------------------------------------------------------------------
% Make the axes available to be pressed by altering properties of objects
% on top of the axes (images).
NameArray = {'HitTest','ButtonDownFcn'};
ValueArray = {'off',''};
set(handles.I2D_IG.Children, NameArray, ValueArray);
set(handles.ID_IG.Children, NameArray, ValueArray);
set(handles.A2D_AG.Children, NameArray, ValueArray);
set(handles.AD_AG.Children, NameArray, ValueArray);
set(handles.FWHM_2D.Children, NameArray, ValueArray);
set(handles.FWHM_G.Children, NameArray, ValueArray);
set(handles.FWHM_D.Children, NameArray, ValueArray);
set(handles.L_a.Children, NameArray, ValueArray);
set(handles.n_d.Children, NameArray, ValueArray);
set(handles.L_d.Children, NameArray, ValueArray);
%--------------------------------------------------------------------------
% Reformat axes so that all objects on top stretch to fill axes.
axis(handles.I2D_IG,'tight'); axis(handles.ID_IG,'tight');
axis(handles.A2D_AG,'tight'); axis(handles.AD_AG,'tight');
axis(handles.FWHM_2D,'tight'); axis(handles.FWHM_G,'tight');
axis(handles.FWHM_D,'tight'); axis(handles.L_a,'tight');
axis(handles.n_d,'tight'); axis(handles.L_d,'tight');

% Save heatmaps,xInd,yInd to handles. xInd may not be necessary.
handles.maps = heatmaps; handles.xInd = xInd; handles.yInd = yInd;
%-------------------------------------------------------------------------
% Initialize current map to display I2D_IG and create rectangle annotation
% of (1,1). Set up current map axes so they can be pressed.
handles.current_map.HitTest = 'on';
handles.current_map.NextPlot = 'add';

% Create heat map image and label axes. Set limits to the data values.
axes(handles.current_map); if handles.plot_white, pcolor(heatmaps{1}); shading flat;
else imagesc(heatmaps{1}); end
handles.current_map.Children.HitTest = 'off';
handles.current_map.Children.ButtonDownFcn = ''; 
xlabel('X','FontSize',10); ylabel('Y','FontSize',10);
colormap(autumn); title('I(2D)/I(G) map','FontSize',11);
colorbar(handles.current_map); axis(handles.current_map,'tight');
% handles.current_map.CLim = [0.6 0.8];

% Create an annotation to show selected area on current map. Order of
% operations (setting annotation parent to axes, then setting position)
% allows for the position to be relative to the axes, not the figure.
ann = annotation('rectangle','HitTest','off','ButtonDownFcn','');
set(ann,'Parent',handles.current_map);
if mod(handles.xInd,2) == 0, handles.xsub = 0; else handles.xsub = 0.5; end
if mod(handles.yInd,2) == 0, handles.ysub = 0; else handles.ysub = 0.5; end
set(ann,'Position',[1-handles.xsub 1-handles.ysub 1 1]);
handles.annotation = ann; handles.xCoor = 1; handles.yCoor = 1;
%-------------------------------------------------------------------------
% Choose default command line output for RamanAnalysis
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);
% UIWAIT makes RamanAnalysis wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = RamanAnalysis_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function slide_Callback(hObject, eventdata, handles)
% hObject    handle to slide (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% Get value of slider. Set slider to only accept integer values.
slide = round(get(hObject,'Value'));
hObject.Value = slide;

% Clear old spectrum from handles.current_spec.
cla(handles.current_spec); axes(handles.current_spec);
% Create a copy of all objects from the spectrum of interest.
specChild = handles.spectra(slide).Children;
% Copy children of original axes to handles.current_spec. Label and title
% the spectrum accordingly.
copyobj(specChild,handles.current_spec);
%axis(handles.current_spec,'tight');
xlabel('Raman shift (cm^{-1})','FontSize',10);
ylabel('Intensity (counts)','FontSize',10);
title(handles.coordinates(slide,:),'FontSize',11);

handles.peakTable.Data = handles.tableparam{1,slide};
set(handles.R2,'String',strcat('R2=',num2str(handles.rsquared(slide))));

% Annotate current map with a box showing selected region. First, calculate
% the coordinates of from the slide number. For example, if slide = 19 and
% there are 20 spectra total (xInd = 5, yInd = 4), then xCoor = 5 and yCoor
% = 3. xCoor is always rounded up to the nearest integer, and yCoor is the
% remainder of slide/yInd.
handles.xCoor = ceil(slide/handles.yInd);
handles.yCoor = slide - (handles.xCoor-1)*handles.yInd;
set(handles.annotation,'Position',[handles.xCoor-handles.xsub handles.yCoor-handles.ysub 1 1]);

guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function slide_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slide (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on mouse press over axes background.
function I2D_IG_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to I2D_IG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Clear current map axes, display heat map on axes, and label the axes.
cla(handles.current_map); axes(handles.current_map);
if handles.plot_white, pcolor(handles.maps{1}); shading flat;
else imagesc(handles.maps{1}); end
handles.current_map.Children.HitTest = 'off'; handles.current_map.Children.ButtonDownFcn = '';
xlabel('X','FontSize',10); ylabel('Y','FontSize',10);
colormap(autumn); title('I(2D)/I(G) map','FontSize',11);
colorbar(handles.current_map); %handles.current_map.CLim = [0.6 0.8];

% Create annotation on heat map.
ann = annotation('rectangle','HitTest','off','ButtonDownFcn','');
set(ann,'Parent',handles.current_map);
set(ann,'Position',[handles.xCoor-handles.xsub handles.yCoor-handles.ysub 1 1]);
handles.annotation = ann;

guidata(hObject,handles);

% --- Executes on mouse press over axes background.
function ID_IG_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to ID_IG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Clear current map axes, display heat map on axes, and label the axes.
cla(handles.current_map); axes(handles.current_map);
if handles.plot_white, pcolor(handles.maps{2}); shading flat;
else imagesc(handles.maps{2}); end
handles.current_map.Children.HitTest = 'off'; handles.current_map.Children.ButtonDownFcn = '';
xlabel('X','FontSize',10); ylabel('Y','FontSize',10);
colormap(autumn); title('I(D)/I(G) map','FontSize',11);
colorbar(handles.current_map); %handles.current_map.CLim = [0.4 0.7];

% Create annotation on heat map.
ann = annotation('rectangle','HitTest','off','ButtonDownFcn','');
set(ann,'Parent',handles.current_map);
set(ann,'Position',[handles.xCoor-handles.xsub handles.yCoor-handles.ysub 1 1]);
handles.annotation = ann;

guidata(hObject,handles);

% --- Executes on mouse press over axes background.
function A2D_AG_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to A2D_AG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Clear current map axes, display heat map on axes, and label the axes.
cla(handles.current_map); axes(handles.current_map);
if handles.plot_white, pcolor(handles.maps{3}); shading flat;
else imagesc(handles.maps{3}); end
handles.current_map.Children.HitTest = 'off'; handles.current_map.Children.ButtonDownFcn = '';
xlabel('X','FontSize',10); ylabel('Y','FontSize',10);
colormap(autumn); title('A(2D)/A(G) map','FontSize',11);
colorbar(handles.current_map); %handles.current_map.CLim = [0.8 1.2];

% Create annotation on heat map.
ann = annotation('rectangle','HitTest','off','ButtonDownFcn','');
set(ann,'Parent',handles.current_map);
set(ann,'Position',[handles.xCoor-handles.xsub handles.yCoor-handles.ysub 1 1]);
handles.annotation = ann;

guidata(hObject,handles);

% --- Executes on mouse press over axes background.
function AD_AG_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to AD_AG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Clear current map axes, display heat map on axes, and label the axes.
cla(handles.current_map); axes(handles.current_map);
if handles.plot_white, pcolor(handles.maps{4}); shading flat;
else imagesc(handles.maps{4}); end
handles.current_map.Children.HitTest = 'off'; handles.current_map.Children.ButtonDownFcn = '';
xlabel('X','FontSize',10); ylabel('Y','FontSize',10);
colormap(autumn); title('A(D)/A(G) map','FontSize',11);
colorbar(handles.current_map); %handles.current_map.CLim = [0.8 1.3];

% Create annotation on heat map.
ann = annotation('rectangle','HitTest','off','ButtonDownFcn','');
set(ann,'Parent',handles.current_map);
set(ann,'Position',[handles.xCoor-handles.xsub handles.yCoor-handles.ysub 1 1]);
handles.annotation = ann;

guidata(hObject,handles);

% --- Executes on mouse press over axes background.
function FWHM_2D_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to FWHM_2D (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Clear current map axes, display heat map on axes, and label the axes.
cla(handles.current_map); axes(handles.current_map);
if handles.plot_white, pcolor(handles.maps{5}); shading flat;
else imagesc(handles.maps{5}); end
handles.current_map.Children.HitTest = 'off'; handles.current_map.Children.ButtonDownFcn = '';
xlabel('X','FontSize',10); ylabel('Y','FontSize',10);
colormap(autumn); title('FWHM-2D map','FontSize',11);
colorbar(handles.current_map); %handles.current_map.CLim = [50 70];

% Create annotation on heat map.
ann = annotation('rectangle','HitTest','off','ButtonDownFcn','');
set(ann,'Parent',handles.current_map);
set(ann,'Position',[handles.xCoor-handles.xsub handles.yCoor-handles.ysub 1 1]);
handles.annotation = ann;

guidata(hObject,handles);

% --- Executes on mouse press over axes background.
function FWHM_G_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to FWHM_G (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Clear current map axes, display heat map on axes, and label the axes.
cla(handles.current_map); axes(handles.current_map);
if handles.plot_white, pcolor(handles.maps{6}); shading flat;
else imagesc(handles.maps{6}); end
handles.current_map.Children.HitTest = 'off'; handles.current_map.Children.ButtonDownFcn = '';
xlabel('X','FontSize',10); ylabel('Y','FontSize',10);
colormap(autumn); title('FWHM-G map','FontSize',11);
colorbar(handles.current_map); %handles.current_map.CLim = [50 70]; 

% Create annotation on heat map.
ann = annotation('rectangle','HitTest','off','ButtonDownFcn','');
set(ann,'Parent',handles.current_map);
set(ann,'Position',[handles.xCoor-handles.xsub handles.yCoor-handles.ysub 1 1]);
handles.annotation = ann;

guidata(hObject,handles);

% --- Executes on mouse press over axes background.
function FWHM_D_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to FWHM_D (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Clear current map axes, display heat map on axes, and label the axes.
cla(handles.current_map); axes(handles.current_map);
if handles.plot_white, pcolor(handles.maps{7}); shading flat;
else imagesc(handles.maps{7}); end
handles.current_map.Children.HitTest = 'off'; handles.current_map.Children.ButtonDownFcn = '';
xlabel('X','FontSize',10); ylabel('Y','FontSize',10);
colormap(autumn); title('FWHM-D map','FontSize',11);
colorbar(handles.current_map); %handles.current_map.CLim = [70 100];

% Create annotation on heat map.
ann = annotation('rectangle','HitTest','off','ButtonDownFcn','');
set(ann,'Parent',handles.current_map);
set(ann,'Position',[handles.xCoor-handles.xsub handles.yCoor-handles.ysub 1 1]);
handles.annotation = ann;

guidata(hObject,handles);

% --- Executes on mouse press over axes background.
function L_a_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to L_a (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Clear current map axes, display heat map on axes, and label the axes.
cla(handles.current_map); axes(handles.current_map);
if handles.plot_white, pcolor(handles.maps{8}); shading flat;
else imagesc(handles.maps{8}); end
handles.current_map.Children.HitTest = 'off'; handles.current_map.Children.ButtonDownFcn = '';
xlabel('X','FontSize',10); ylabel('Y','FontSize',10);
colormap(autumn); title('L_a map','FontSize',11);
colorbar(handles.current_map); %handles.current_map.CLim = [10 20];

% Create annotation on heat map.
ann = annotation('rectangle','HitTest','off','ButtonDownFcn','');
set(ann,'Parent',handles.current_map);
set(ann,'Position',[handles.xCoor-handles.xsub handles.yCoor-handles.ysub 1 1]);
handles.annotation = ann;

guidata(hObject,handles);

% --- Executes on mouse press over axes background.
function n_d_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to n_d (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Clear current map axes, display heat map on axes, and label the axes.
cla(handles.current_map); axes(handles.current_map);
if handles.plot_white, pcolor(handles.maps{9}); shading flat;
else imagesc(handles.maps{9}); end
handles.current_map.Children.HitTest = 'off'; handles.current_map.Children.ButtonDownFcn = '';
xlabel('X','FontSize',10); ylabel('Y','FontSize',10);
colormap(autumn); title('n_d map','FontSize',11);
colorbar(handles.current_map); %handles.current_map.CLim = [2e11 4e11];

% Create annotation on heat map.
ann = annotation('rectangle','HitTest','off','ButtonDownFcn','');
set(ann,'Parent',handles.current_map);
set(ann,'Position',[handles.xCoor-handles.xsub handles.yCoor-handles.ysub 1 1]);
handles.annotation = ann;

guidata(hObject,handles);

% --- Executes on mouse press over axes background.
function L_d_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to L_d (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Clear current map axes, display heat map on axes, and label the axes.
cla(handles.current_map); axes(handles.current_map);
if handles.plot_white, pcolor(handles.maps{10}); shading flat;
else imagesc(handles.maps{10}); end
handles.current_map.Children.HitTest = 'off'; handles.current_map.Children.ButtonDownFcn = '';
xlabel('X','FontSize',10); ylabel('Y','FontSize',10);
colormap(autumn); title('L_d map','FontSize',11);
colorbar(handles.current_map); %handles.current_map.CLim = [8 12];

% Create annotation on heat map.
ann = annotation('rectangle','HitTest','off','ButtonDownFcn','');
set(ann,'Parent',handles.current_map);
set(ann,'Position',[handles.xCoor-handles.xsub handles.yCoor-handles.ysub 1 1]);
handles.annotation = ann;

guidata(hObject,handles);

% --- Executes on mouse press over axes background.
function current_map_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to current_map (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get current point. Change annotation position to current point.
cp = get(handles.current_map,'CurrentPoint');
x = round(cp(1,1)); y = round(cp(1,2));
set(handles.annotation,'Position',[x-0.5 y-0.5 1 1]);
handles.xCoor = x; handles.yCoor = y;

% Move slider position and change the current spectrum displayed.
slide = (x-1)*handles.yInd + y;
handles.slide.Value = slide;
cla(handles.current_spec); axes(handles.current_spec);
specChild = handles.spectra(slide).Children;
copyobj(specChild,handles.current_spec);
axis(handles.current_spec,'tight');
xlabel('Raman shift (cm^{-1})','FontSize',10);
ylabel('Intensity (counts)','FontSize',10);
title(handles.coordinates(slide,:),'FontSize',11);

handles.peakTable.Data = handles.tableparam{1,slide};
set(handles.R2,'String',strcat('R2=',num2str(handles.rsquared(slide))));

guidata(hObject,handles);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

curr_dir = pwd;
%{
if handles.varargin{1,3}(2)
    writetable(handles.table,'table.xlsx','WriteRowNames',true);
    m = msgbox('Operation complete: Table exported');
    pause(3);
    delete(m);
end

%open figure, display handles.spec(:), save each as title
if handles.varargin{1,3}(1)
    if ~exist(strcat(curr_dir,'\spectra'),'dir'), mkdir('spectra'); end
    cd('spectra');
    n = 1;
    while n <= length(handles.spectra)
        figure('Position',[1 1 1350 650],'Name','spectra');
        t = uitable(gcf,'Position',[500 490 410 95],'ColumnName',{'Intensity',...
        'Area','Frequency','FWHM','Offset'},'RowName',{'D','G','2D','D'''});
        % add R2 text in position
        xlabel('Raman shift (cm^{-1})');
        ylabel('Intensity (counts)');
        specChild = handles.spectra(n).Children;
        copyobj(specChild,gca); axis(gca,'tight');
        title(handles.coordinates(n,:));
        t.Data = handles.tableparam{1,n};
        saveas(gcf,strcat(handles.coordinates(n,:),'.jpg'));
        h =  findobj('type','figure');
        if length(h) > 10, close spectra; end
        n = n+1;
    end
    close spectra;
    cd(curr_dir);
end

%create distributions, save to folder called 'distributions'
if handles.varargin{1,3}(4)
    if ~exist(strcat(curr_dir,'\distributions'),'dir'), mkdir('distributions'); end
    cd('distributions');
    distribution(handles.table,20);
    close distributions;
    cd(curr_dir);
end

%open figure, display handles.maps
if handles.varargin{1,3}(3)
    if ~exist(strcat(curr_dir,'\maps'),'dir'), mkdir('maps'); end
    cd('maps');
    names = {'I2D_IG' 'ID_IG' 'A2D_AG' 'AD_AG' 'FWHM-2D' 'FWHM-G' 'FWHM-D'...
        'L_a' 'n_d' 'L_d'};
    titles = {'I2D/IG' 'ID/IG' 'A2D/AG' 'AD/AG' 'FWHM-2D' 'FWHM-G' 'FWHM-D'...
        'L_a' 'n_d' 'L_d'};
    %clim = {[0.6 0.8] [0.4 0.7] [0.8 1.2] [0.8 1.3] [50 70] [30 50]...
    %    [70 100] [10 20] [2e11 4e11] [8 12]};
    for n = 1:length(handles.maps)
        figure('Name','maps');
        pcolor(handles.maps{n}); shading flat; colormap(autumn); colorbar;
        title(titles{n});
        %set(gca,'CLim',clim{n});
        xlabel('X'); ylabel('Y');
        saveas(gcf,strcat(names{n},' map.jpg'));
    end
    close maps;
    cd(curr_dir);
end
%}
% Hint: delete(hObject) closes the figure
delete(hObject);