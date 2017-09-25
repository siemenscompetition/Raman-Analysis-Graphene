# Raman-Analysis-Graphene
Raman map analysis of graphene, available in command line (CL) and graphical user interface (GUI) versions.
A set of MATLAB codes for analyzing Raman maps. The input file is a .txt Raman map file with format:
 - 1st row: x-coordinate at which spectrum was taken
 - 2nd row: y-coordinate at which spectrum was taken
 - 1st column: Raman shifts/frequencies/wavenumber (cm^-1)
 - 2nd column to last column: intensities (counts)

Add the folder of CL functions to the MATLAB path and paste the main
script ('CL_main') into the folder containing the Raman map file.

CL functions:
 - 'readRamanFiles': processes the Raman map text file
 - 'fourPeaks': fits four Lorentzians (D, G, D', and 2D peaks) using
	the Curve Fitting Toolbox
 - 'plotSpectrum': fits a single spectrum with Lorentzians and returns
	array of parameters (intensities, areas, frequencies, FWHMs, Ld, La)
 - 'makeTable': compiles parameter arrays from 'plotSpectrum' into a
	table with '(x-coordinate,y-coordinate)' as row names
 - 'distribution': plots the distribution for each parameter in table
 - 'heatMap': creates Raman maps of peak parameters
 
 Outputs:
 - folder named 'spectra' with .bmp files of spectra at each coordinate
 - folder named 'distributions' with .bmp files of parameter distributions
 - folder named 'maps' with .bmp files of Raman maps for each parameter
 - Excel table named 'table' with peak parameters for each coordinate
 - Excel table named 'summary' with average peak parameters
