FileDirectory = getDirectory("Choose Source Directory ")
OutputDirectory = getDirectory("Choose Destination Directory ");
list = getFileList(FileDirectory);
setBatchMode(true);


//Read text image and save a 32-bit tiff
for (i=0; i<list.length; i++) {
  file = FileDirectory + list[i];
  print(file);
  run("Text Image... ", "open=[" + file + "]");
  dotIndex = indexOf(list[i], ".txt");
  title = substring(list[i], 0, dotIndex);
  Path1 = OutputDirectory + title + ".tiff";
  saveAs("Tiff", Path1);
}

//Get tiffs
list2 = getFileList(OutputDirectory);
for (i=0; i<list2.length; i++) {
 showProgress(i+1, list2.length);
 filename = OutputDirectory + list2[i];
 if (endsWith(filename, "tiff")) {
 	open(filename);
 	selectWindow(list2[i]);
 	
 	// Filter and align rows
	run("Bandpass Filter...", "filter_large=50 filter_small=1 suppress=Horizontal tolerance=5 autoscale saturate");
	run("Gaussian Blur...", "sigma=1");

	// Set to nanometres if height image
	//run("Multiply...", "value=1000000000");
	selectWindow(list2[i]);
	
	// Get mean of current image and set to zero
	getStatistics(area, mean, min, max, std, histogram);
	run("Subtract...", "value="+mean);
	
	// Save
	selectWindow(list2[i]);
	dotIndex = indexOf(list2[i], ".tiff");
	title = substring(list2[i], 0, dotIndex);
	Path3 = OutputDirectory + title + "_Filtered.tiff";
    saveAs("Tiff", Path3);
    
 }
}

print('done')


close("*")