title = getTitle(); 
dir = "";
dotIndex = indexOf(title, "tif") - 1; 
name = substring(title, 0, dotIndex);
skeletonname = name + "_skeleton";
skelsave = dir + "output/" + skeletonname + ".tif";
longestpaths = dir + "output/" + name + "labelled_skel.tif";
branchinfo = dir + "output/" + name + "Branch_information.txt";
marked = dir + "output/" + name + "marked.tif";

//Get marked MACs as filled circles
selectWindow(title);
run("Set Scale...", "distance=1 known=1 pixel=1 unit=nm");
run("8-bit");
setThreshold(88, 109);
run("Convert to Mask");
run("Fill Holes");
run("Despeckle");

//Skeletonise and remove very small paths due to single MACs
run("Duplicate...", " ");
rename(skeletonname);
run("Skeletonize");
run("Dilate");
run("Analyze Particles...", "size=25-Infinity pixel show=Masks display");

//Save skeleton
selectWindow("Mask of " + skeletonname);
save(skelsave);
close("Results");

//Analyse skeleton
run("Invert");
run("Skeletonize");
run("Invert");
run("Analyze Skeleton (2D/3D)", "prune=none calculate show display");
selectWindow("Branch information");
close();
close("Results");

//Get longest branches only
selectWindow("Longest shortest paths");
setThreshold(96, 96);
run("Convert to Mask");
run("Make Binary");
run("Invert");
selectWindow("Tagged skeleton");
setThreshold(30, 70);
run("Convert to Mask");
run("Make Binary");
run("Invert");
imageCalculator("AND create", "Longest shortest paths","Tagged skeleton");
selectWindow("Result of Longest shortest paths");
run("Invert");
run("Analyze Particles...", "size=4-Infinity pixel show=Masks display");
close("Results");

//Get lengths of longest branches and save results
run("Analyze Skeleton (2D/3D)", "prune=none calculate show display");
selectWindow("Branch information");
save(branchinfo);
selectWindow("Mask-labeled-skeletons");
run("RGB Color");
save(longestpaths);
close("Results");

//Save MACs marked with branches
selectWindow("Mask of Result of Longest shortest paths");
run("Maximum...", "radius=3");
run("Fire");
run("Max...", "value=211");
selectWindow(title);
run("Fire");
run("Max...", "value=85");
imageCalculator("Transparent-zero create", title, "Mask of Result of Longest shortest paths");
selectWindow("Result of "+title);


run("Duplicate...", " ");
rename("white");
run("Min...", "value=255");
imageCalculator("Transparent-zero create", "white","Result of "+title);
save(marked);

close("*")


