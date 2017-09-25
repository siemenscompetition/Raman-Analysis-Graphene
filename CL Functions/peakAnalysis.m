function values = peakAnalysis(x,y,peakname)
%  given peakname 2D, G, or D, return peak values = [intensity, freq, offset]
%  original peak parameters, not fitted

%  set initial peak ranges based on input
switch peakname
	case '2D'
		peak = x>2500 & x<2800; %peak range
		pristinePeak = 2690;
	case 'G'
		peak = x>1500 & x<1700; %peak range
		pristinePeak = 1580;
	case 'D'
		peak = x>1250 & x<1450; %peak range
		pristinePeak = 1350;
end

%  plots the peak in the specific peak range
%figure
%plot(x(peak),y(peak),'-')
%xlabel('Raman shift (cm^{-1})')
%ylabel('Intensity (counts)')

minIndex = find(peak,1); %min index
maxIndex = find(peak,1,'last'); %max index

%  set each value in values
[ intensity, index ] = max(y(peak)); %find max intensity
xIndex = minIndex + index - 1; %Since peak has shifted indices, add minIndex-1
freq = x(xIndex); %x value at xIndex
offset = freq - pristinePeak; %x offset

%  if the maximum value occurs at the leftmost range, this means there is
%  no peak: continuously decreasing function
if xIndex == minIndex
    values = [0 0 0];
else
    values = [intensity freq offset];
end

end