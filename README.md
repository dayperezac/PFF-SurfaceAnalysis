---README---
This macro was written for ImageJ Fiji
Macro Name:
Channel_quantification_macro_V1_20261019


Image format
.tif

Image type:
Multichannel Z- projections. 


Macro Description. 

This macro was designed to quantify the area coverage of one channel (To Measure) onto a Mask or Thresholding Channel. 
This macro is used routinely to quantify antibody binding or positive signal on neurons, using a neuron mask such as MAP2 or fluorescent fill (ex. GFP, mCherry, TdTom). 

To use, all images with unique identifiers must be in the same folder. (If files other than TIF are in the same folder, it will cause the macro to stop. 

Users must indicate 
-Directory with Images to Analyze. 

Output Folder. Create a new folder before starting. This will contain the verification images and csv for results. 

Experiment info:

	-Pixel Scale. Current Scale 0.10049847 is the value for our Microscope Images (Andor Dragonfly). 
	-Number of Channels 
	-File index, tif. 

Channel Assignment

	Choose the Channel for Thresholding. This is the one to create the Neuron Mask
	Channel to Measure. This is the channel for the signal to measure. 
	Primary Thresholding. Method for Neuron Mask Thresholding. 
	Secondary Thresholding. Method for signal-to-measure thresholding. 
		Thresholding Methods
		 Manual
		 Set Value
		 Auto
		 From CSV. (If each image requires a different threshold value, a CSV with the names of the files and individual threshold values can be used) 
	Name of Channels. Indicate the name of your markers. 



Analysis
	CSV file with quantification areas and Verification images for the thresholded masks, and the signal inside the ROI will be saved in the output folder
