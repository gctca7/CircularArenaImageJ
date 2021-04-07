// list ufmf files
// find reciprocal experiments
// open each ufmf one by one
// detect circular arena
// calculate PI based on number of pixels occupied by flies
// output time course of PI and summary table for last 30s PI of 2min test
// assumption: Movie is 1024x1024. Diameter of arena is 910. FPS is 30. Lenght of test period is 2min. folder name of ufmf contains experimental information separated by "_" in a specific order. 

Diameter = 910; //inner diameter of arena inside the ring (pixels)
ReductionFactor=10; //factor to resize in Z. 10 for FPS=30 means calculate mean PIs for every 1/3 second.
FPS= 30/ReductionFactor;

Resize=910/910;
run("Input/Output...", "jpeg=80 gif=-1 file=.txt copy_row save_column save_row"); // parameters for plots
run("Colors...", "foreground=white background=black selection=yellow"); // parameters for plots
run("Set Measurements...", "decimal=4");
run("Clear Results"); 

dir = getDirectory("Choose a main directory of data"); //choose a folder to analyze. choose each date folder
dirSave= dir;

//Recursively list ufmf files and classify them into reciprocal experiments
listFiles(dir); 
  function listFiles(dir) {
     list = getFileList(dir);
     Array.sort(list);
     for (l=0; l<list.length; l++) {
        if (endsWith(list[l], "/"))       
           listFiles(""+dir+list[l]);
        else{
        	Path = dir + list[l];
			if (endsWith(Path, ".ufmf")){
			    Directory = split(replace(substring(dir, 0, lengthOf(dir)-1), "/", "\\"),"\\");
			    GenotypeProtocol = split(Directory[Directory.length-1],"_"); //return an array containing genotype, protocol, rig, arena from folder name
			    MovieName=split(list[l],"_");
			    //skip if movie name contains "Train" or "train"
			    if(indexOf(list[l], "Train" )<0 && indexOf(list[l], "train" )<0 ){
			    	if(indexOf(GenotypeProtocol[3], "rec1")>=0 ||   indexOf(GenotypeProtocol[3], "OCT+")>=0 || indexOf(GenotypeProtocol[3], "PA+")>=0){
						setResult("Reciprocal",nResults, 1);
			   	 	}
			    	if(indexOf(GenotypeProtocol[3], "rec2")>=0 || indexOf(GenotypeProtocol[3], "MCH+")>=0 ||  indexOf(GenotypeProtocol[3], "BA+")>=0 || indexOf(GenotypeProtocol[3], "EL+")>=0){
						setResult("Reciprocal",nResults, 2);
			   		}
			    	setResult("Male",nResults-1, GenotypeProtocol[4]);
					setResult("Female",nResults-1, GenotypeProtocol[5]);
					setResult("Protpcol",nResults-1, GenotypeProtocol[3]);
					setResult("Rig",nResults-1, GenotypeProtocol[1]);
					setResult("Arena",nResults-1, GenotypeProtocol[2]);
					setResult("Movie",nResults-1, MovieName[1]);
					setResult("Experimental-information-and-Path",nResults-1,  GenotypeProtocol[4]+"$"+GenotypeProtocol[5]+"$"+GenotypeProtocol[3]+"$"+GenotypeProtocol[1]+"$"+GenotypeProtocol[2]+"$"+GenotypeProtocol[0]+"$"+MovieName[1]+"$"+Path);
			    }
			}
        }
     }
  }
updateResults;


//list reciprocal #1 and #2 experiments separately
ListRec1=newArray();
ListRec2=newArray();
for(i=0;i<nResults;i++){
	if(getResult("Reciprocal",i)==1){
		ListRec1=Array.concat(ListRec1, getResultString("Experimental-information-and-Path",i));
	}
	if(getResult("Reciprocal",i)==2){
		ListRec2=Array.concat(ListRec2, getResultString("Experimental-information-and-Path",i));
	}
}

//sort reciprocal #1 and #2 experiments
ListRec1=Array.sort(ListRec1);
ListRec2=Array.sort(ListRec2);
run("Clear Results");

//match up reciprocal experiments and calculate PIs
if(ListRec1.length!=ListRec2.length){
	print("Error: numbers of Reciprocal#1 experiments and Reciprocal#2 experiments do not match");
}
else{
  	GenotypeProtocolArenaMismatch = 0;
  	for(i=0;i<ListRec1.length;i++){
  		Rec1=split(ListRec1[i],"$");
  		Rec2=split(ListRec2[i],"$");
		Rec1Info= Rec1[0]+Rec1[1]+Rec1[3]+Rec1[4];
  		Rec2Info= Rec2[0]+Rec2[1]+Rec2[3]+Rec2[4];
  		if(Rec1Info!=Rec2Info){
			GenotypeProtocolArenaMismatch =1;
			print("Error: no reciprocal experiment for"+Rec1[7]);
  		}
  		else{
  			setResult("Male",nResults, Rec1[0]);
			setResult("Female",nResults-1, Rec1[1]);
			setResult("Protpcol_rec1",nResults-1, Rec1[2]);
			setResult("Protpcol_rec2",nResults-1, Rec2[2]);
			setResult("Rig",nResults-1, Rec1[3]);
			setResult("Arena",nResults-1, Rec1[4]);
			setResult("Time_rec1",nResults-1, Rec1[5]);
			setResult("Time_rec2",nResults-1, Rec2[5]);
			setResult("Movie",nResults-1, Rec1[6]);
			setResult("Rec1_Path",nResults-1,  Rec1[7]);
			setResult("Rec2_Path",nResults-1,  Rec2[7]);
  		}
  	}
  	updateResults;
  	selectWindow("Results");
    saveAs("Results",  dirSave +"ufmf_file_list"+".csv"); 
  	if(GenotypeProtocolArenaMismatch==0){
  		print("All reciprocal experiments were found succesfully");
        for(i=0;i<ListRec1.length;i++){
        	setResult("Reciprocal-PI-last30s",i, "Calculating");
        }
  		updateResults;
  		for(i=0;i<ListRec1.length;i++){
  			Rec1=split(ListRec1[i],"$");
  			Rec2=split(ListRec2[i],"$");
  			PI1= PItimecourse(Rec1[7]); //run "PItimecourse" function below for the specified file path
			PI2= PItimecourse(Rec2[7]); //run "PItimecourse" function below for the specified file path

			//calculate reciprocal PIs. The length of array is adjusted to shorter one of two reciprocal experiments.
			if(PI1.length<=PI2.length){
				PIReciprocal = newArray(PI1.length);
				for(j=0;j<PI1.length;j++){
					PIReciprocal[j]=(PI1[j]-PI2[j])/2;				
				}
			}
			else{
				PIReciprocal = newArray(PI2.length);
				for(j=0;j<PI2.length;j++){
					PIReciprocal[j]=(PI1[j]-PI2[j])/2;				
				}
			}
			Array.getStatistics(Array.slice(PI1,271,360), min, max, mean, std); // array statistics for the specified period.  271-360 is last 30s of 2 min movie
			PI1Last30s=mean;
			Array.getStatistics(Array.slice(PI2,271,360), min, max, mean, std);
			PI2Last30s=mean;
		    Array.getStatistics(Array.slice(PIReciprocal,271,360), min, max, mean, std);
			
			PILast30s= mean;
            Time = Array.getSequence(PIReciprocal.length);
			for(t=0;t<Time.length;t++){
				Time[t]= Time[t]/3;
			}
			TimeEnd = round(PIReciprocal.length/3);	
			setBatchMode("exit & display");	//somehow plotting below doesnot work in hide mode

			//Plot PI time course
		    Plot.create("Performance Index (PI)", "Time (Second)", "PI Reciprocal (perference to CS+)", Time, PIReciprocal);
			Plot.setColor("red");
			Plot.setLimits(0, TimeEnd, -1, 1);
			Plot.show();
			run("RGB Color");
			rename("1");

		    Plot.create("Performance Index (PI)", "Time (Second)", "PI Reciprocal#1 (perference to Quadrant 1 and 4)", Time, PI1);
			Plot.setColor("red");
			Plot.setLimits(0, TimeEnd, -1, 1);
			Plot.show();
			run("RGB Color");
			rename("2");

		    Plot.create("Performance Index (PI)", "Time (Second)", "PI Reciprocal#2 (perference to Quadrant 1 and 4)", Time, PI2);
			Plot.setColor("red");
			Plot.setLimits(0, TimeEnd, -1, 1);
			Plot.show();
			run("RGB Color");
			rename("3");
			run("Combine...", "stack1=1 stack2=2");
			rename("1and2");
			run("Combine...", "stack1=1and2 stack2=3");


            Path1= dirSave+Rec1[0]+"_"+Rec1[1]+"_"+Rec1[2]+"_"+Rec1[3]+"_"+Rec1[4]+"_"+Rec1[5]+"_"+Rec1[6]+"_plot.jpg";
            makeRectangle(367, 7, 227, 5);
			setBackgroundColor(0, 0, 0);
			run("Clear", "slice");
            saveAs("Jpeg",Path1);
			setResult("Reciprocal-PI-last30s",i, PILast30s);
			setResult("PI1-last30s",i, PI1Last30s);
			setResult("PI2-last30s",i, PI2Last30s);
			updateResults;
           
			print((i+1)+"/"+ListRec1.length+"files finished");
			run("Close All");
			
  		}
  		
  	}
  }
   saveAs("Results",  dirSave +"ufmf_file_list"+".csv"); 





function PItimecourse(Path) {
	run("Import UFMF", "choose=Path"); //open ufmf files. needs ufmf reader plugin
	setBatchMode("hide");
    Original_ufmf = getImageID();					
	Directory = getDirectory("image");
	title0 = substring(getTitle(),0, lengthOf(getTitle())-5);
	PathBackground = Directory + title0+"_Max.jpg";
	print("opening ufmf file:"+Path);
	getDimensions(width, height, channels, slices, frames);
	WidthMinusDiameter = width - Diameter;
	if(Resize==1){
    	run("Duplicate...", "title=original duplicate"); //to process images since ufmf reader opens stacks in virtual mode.
	}
	else{
		run("Scale...", "x=Resize y=Resize z=1.0 width=1319 height=1055 depth=nSlices	interpolation=Bilinear process create");
		rename("original");
		makeRectangle(144, 6, 1024, 1024);
		run("Crop");
		if(indexOf(title0, "cam_1")>=0){
			run("Rotate... ", "angle=1 grid=1 interpolation=Bilinear");
		}
	}
	
	run("Reduce...", "reduction=ReductionFactor"); // reduce in Z
	Original = getImageID();
	NSLICES = nSlices-1;
    selectImage(Original_ufmf);
    close();		
	//Find arena, then substract background. Save MIN stack as JPEG and AVI
	print("Detecting a circular arena of 910pix diameter");
	if (width ==1024){
		
		run("Z Project...", "projection=[Max Intensity]");
		run("Select All");
		getStatistics(area, mean, min, max, std, histogram);
		MEAN = mean;
		//measure mean intensity inside the 910 diameter circles. search 30x30 different positions in x and y at 3pix steps 
		for (i=0; i<30; i++) {
			for (j=0; j<30; j++) {
				makeOval(3*i, 3*j, Diameter, Diameter);
				getStatistics(area, mean, min, max, std, histogram);
				if (mean>MEAN){
					X = -1*3*i;
					Y = -1*3*j;
					MEAN = mean;
				}
			}
		}
		selectWindow("MAX_original");
		close();
		selectImage(Original);
		run("Translate...", "x=X y=Y interpolation=None stack"); 
		makeRectangle(0, 0, Diameter, Diameter);
		run("Crop"); // the center of this cropped image is center of arena
		selectImage(Original);
		run("Z Project...", "projection=[Max Intensity]");
		imageCalculator("Difference stack", "original","MAX_original"); // to obtain background subtracted images
		selectWindow("MAX_original");
		saveAs("Jpeg",  PathBackground); 
		close();
		selectImage(Original);
		run("Select All");
		getStatistics(area, mean, min, max, std, histogram);
		HistgramstretchingRatio = 255/max;
		run("Multiply...", "value=HistgramstretchingRatio stack"); //histogram stretching to normalize image brightness variation accross rigs
	}		
	selectImage(Original);
	rename("original");
	PItime=newArray(nSlices);
	selectImage(Original);
	getStatistics(area, mean, min, max, std, histogram);
	Mean3SD = mean + 3*std;
	setThreshold(Mean3SD, 255);
	run("Convert to Mask", "method=Default background=Dark black");
  
    //calculate PI by pixel
	for(i=1;i<=nSlices;i++){
		
		selectImage(Original);
		setSlice(i);
		makeRectangle(0, 0, 455, 455);
		getStatistics(area, mean, min, max, std, histogram);
		Q1 = mean;
		makeRectangle(455, 0, 455, 455);
		getStatistics(area, mean, min, max, std, histogram);
		Q2 = mean;
        makeRectangle(0, 455, 455, 455);
		getStatistics(area, mean, min, max, std, histogram);
		Q3 = mean;
		makeRectangle(455, 455, 455, 455);
		getStatistics(area, mean, min, max, std, histogram);
		Q4 = mean;
		Q1Q4 = Q1+Q4;
		Q2Q3 = Q2+Q3;
		PItime[i-1] = (Q1Q4-Q2Q3)/(Q1Q4+Q2Q3);
		}
    run("Close All");
    return PItime; 
} 

  

 

  
  