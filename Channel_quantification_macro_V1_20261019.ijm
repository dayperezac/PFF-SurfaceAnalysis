//Macro for quantifying the area of one channel (measured channel) inside the thresholded mask of another channel (mask channel), e.g. pSyn inside MAP2.
//The names of the two channels are entered in the "Channel Assignment" dialog and are used for output folders and file names.
//This macro was updated by Dayana 2026/05/21 to include images that have no signal. 
//Updated 2026/10/19: also saves a second verification image showing only the measured-channel signal inside the mask (_<name>-inside<mask>only.tif)
//Updated 2026/10/19: channel names are now entered in a dialog instead of being fixed as MAP2 / pSyn


input = getDirectory("Choose folder for starting images");
File.setDefaultDir(input);
output=getDirectory("Choose output folder");
list = getFileList(input);
list = Array.sort(list);
var indvthreshold, noise, areapercent, scale, minsize, maxsize, name, noise, count, axonlength, axonflag, name, newname;
var string, j, d, sum, indexstring, indexnum, tvalue, Label2Array, resultlist, FolderCreate, foldername, FO, findex, LabelArray, CS, nindex, length, axonlength;

//Channel/Scale/Thresholding parameters
Dialog.create("Experiment Info");
Dialog.addNumber("Pixel Scale:", 0.10049847,8,8,"(um/pixel)");
Dialog.addNumber("How many starting channels?",4,0,1,"channel/s");
Dialog.addString("Name Index", ".tif");
Dialog.show();
scale = Dialog.getNumber();
numChan = Dialog.getNumber();
nameindex = Dialog.getString();

channel= newArray("C1","C2","C3","C4");
chan=Array.trim(channel, numChan);

options = newArray("Manual","Auto","Set Value", "From .csv");
options2 = newArray("Manual","Auto","Set Value", "From .csv","None");
Dialog.create("Channel Assignment");
Dialog.addChoice("Channel for Thresholding", chan);
Dialog.addChoice("Channel to Measure", chan);
Dialog.addChoice("Primary Thresholding", options);
Dialog.addChoice("Secondary Thresholding", options2);
Dialog.addString("Name of thresholding (mask) channel", "MAP2");
Dialog.addString("Name of measured channel", "pSyn");
Dialog.show();

tchan=Dialog.getChoice();
mchan=Dialog.getChoice();
tvalue = Dialog.getChoice();
mvalue = Dialog.getChoice();
maskName = Dialog.getString();
measName = Dialog.getString();

//Generating output folders
zipfile = output+"ROIs";
MAP2maskImage = output+ maskName+"-Mask Images";
pSynInROI = output+measName+" into "+maskName;
File.makeDirectory(zipfile);
File.makeDirectory(MAP2maskImage);
File.makeDirectory(pSynInROI);


//Loading .csv with individual file thresholding		
if ((tvalue== "From .csv"||mvalue == "From .csv")==1){
	path2 = File.openDialog("Select a .csv of threshold measurements");
	Table.open(path2);
	Table.rename(Table.title, "Threshold");
	Label2Array=newArray();
	Label2Array=Table.getColumn("File");
}

if (tvalue == "Set Value") {
	Dialog.create("Set Thresholding");
	Dialog.addNumber(maskName+" ("+tchan+") Threshold",0);
	Dialog.show();
	settval=Dialog.getNumber();
}
if (mvalue == "Set Value") {
	Dialog.create("Set Thresholding");
	Dialog.addNumber(measName+" ("+mchan+") Threshold",0);
	Dialog.show();
	setmval=Dialog.getNumber();
}

run("Set Measurements...", "area mean perimeter integrated area_fraction limit display redirect=None decimal=5");

for(f=0;f<list.length;f++)
{
	open(input+list[f]);
	x=0;
	y=0;
	a=65535;
	title=getTitle();
	endindex=indexOf(title, nameindex);
	newtitle=substring(list[f],0,endindex);

	selectImage(title);
	run("Split Channels");
	
	selectWindow(tchan+"-"+title);
	roiManager("reset");
	getDimensions(width, height, channels, slices, frames);
	run("Properties...", "channels=1 slices=1 frames=1 unit=um pixel_width="+scale+" pixel_height="+scale+" voxel_depth=1");
	resetThreshold;
	run("Grays");

	if (tvalue == "Auto") {
		setAutoThreshold("Default dark 16-bit no-reset");
		run("Threshold...");
	}
	if(tvalue == "Manual"){
		run("Threshold...");
		waitForUser("Set threshold for "+maskName+" ("+tchan+") and click OK");
	}
	if(tvalue == "Set Value"){
		x=settval;
		setThreshold(x, 65535);
		run("Apply LUT");
	}
	if (tvalue == "From .csv"){
		for (i = 0; i < lengthOf(Label2Array); i++) {
			if (startsWith(Label2Array[i],newtitle)) {
				selectWindow("Threshold");
				x=Table.get(tchan, i);
			}
		}
	}
	
	
	run("Create Selection");
	roiManager("Add");
	roiManager("Select", 0);
	roiManager("Rename", title+" "+tchan+" "+x);
	roiManager("Measure");// This measures the mask area
	roiManager("save", zipfile+File.separator+newtitle+tchan+" T"+x+"_ROI.zip");
	// Draw the ROI border on the image
	run("Draw");

	// Save image into the folder
	saveAs("Tiff", MAP2maskImage + File.separator + newtitle+tchan+" T"+x+"_"+maskName+"withROI.tif");

	selectWindow(mchan+"-"+title);

	if(mvalue != "None"){
		resetThreshold;
		run("Grays");
		if (mvalue == "Auto") {
			setAutoThreshold("Default dark");
			run("Threshold...");
		}
		if(mvalue == "Manual"){
			run("Threshold...");
			waitForUser("Set threshold for "+measName+" ("+mchan+") and click OK");
		}
		if(mvalue == "Set Value"){
			y=setmval;
			setThreshold(y, 65535);
			run("Apply LUT");
		}
		if (mvalue == "From .csv"){
			for (i = 0; i < lengthOf(Label2Array); i++) {
				if (startsWith(Label2Array[i],newtitle)) {
					selectWindow("Threshold");
					y=Table.get(mchan, i);
				}
			}
		}
		
	// Create selection for the measured channel
	run("Create Selection");

	// Check if any selection exists
	if (selectionType() == -1) { // -1 means no selection — no signal detected

		// ROW 2: full measured-channel measurement (zero — no signal)
		// Matches: "2 C2-...-F00 MAX.tif" row in working output
		n = nResults;
		setResult("Label",     n, mchan + "-" + title);
		setResult("Area",      n, 0);
		setResult("Mean",      n, 0);
		setResult("Min",       n, 0);
		setResult("Max",       n, 0);
		setResult("Perim.",    n, 0);
		setResult("IntDen",    n, 0);
		setResult("%Area",     n, 0);
		setResult("RawIntDen", n, 0);
		setResult("MinThr",    n, y);
		setResult("MaxThr",    n, 65535);
		updateResults();

		// ROW 3: measured channel within mask ROI measurement (zero — no signal)
		// Matches: "3 C2-...-F00 MAX.tifThresholded in ROI" row in working output
		n = nResults;
		setResult("Label",     n, mchan + "-" + title + "Thresholded in ROI");
		setResult("Area",      n, 0);
		setResult("Mean",      n, 0);
		setResult("Min",       n, 0);
		setResult("Max",       n, 0);
		setResult("Perim.",    n, 0);
		setResult("IntDen",    n, 0);
		setResult("%Area",     n, 0);
		setResult("RawIntDen", n, 0);
		setResult("MinThr",    n, y);
		setResult("MaxThr",    n, 65535);
		updateResults();

		// Draw cell mask ROI on the measured-channel image and save verification image
		roiManager("Select", 0);
		run("Draw");
		saveAs("Tiff", pSynInROI + File.separator + newtitle + mchan + " T" + y + "_" + measName + "-withinROI.tif");

	} else {
		// Signal is present — run normal workflow

		roiManager("Add");
		roiManager("deselect");
		roiManager("Select", 1);
		roiManager("Rename", title + " " + mchan + " " + y);
		roiManager("Measure"); // measure entire measured-channel area (Row 2)

		rename(mchan + "-" + title + "Thresholded in ROI");

		roiManager("deselect");
		roiManager("Select", 0);
		roiManager("Measure"); // measure measured-channel area inside mask ROI (Row 3)
		roiManager("save", zipfile + File.separator + newtitle + "_ROI.zip");

		// Save a second verification image with ONLY the measured-channel signal inside the mask
		// (everything outside the mask ROI is set to 0 on a duplicate; the measured image is untouched)
		origTitle = getTitle();
		run("Select None");
		run("Duplicate...", "title=signal_inside_mask");
		roiManager("Select", 0);
		run("Make Inverse");
		setColor(0);
		fill();
		run("Select None");
		saveAs("Tiff", pSynInROI + File.separator + newtitle + mchan + " T" + y + "_" + measName + "-inside" + maskName + "only.tif");
		close();
		selectWindow(origTitle);
		roiManager("Select", 0);

		// Draw ROI border on image
		run("Draw");

		// Save verification image
		saveAs("Tiff", pSynInROI + File.separator + newtitle + mchan + " T" + y + "_" + measName + "-withinROI.tif");
	}
	}
	close("*");
	roiManager("reset");
}
roiManager("reset");
selectWindow("Results");
getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
newmonth=month+1;
print(year+"-"+newmonth+"-"+dayOfMonth);
saveAs("Results",output+File.separator+year+"-"+newmonth+"-"+dayOfMonth+" Results.csv");
