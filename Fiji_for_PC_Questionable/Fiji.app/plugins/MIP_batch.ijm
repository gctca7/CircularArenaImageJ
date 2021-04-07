//Hideo Otsuna (HHMI Janelia Research Campus), June 4, 2015

autothre=0;//1 is 
setBatchMode(true);
compCC=0;// 1 is compressed nrrd, 0 is not compressed nrrd
keepsubst=0; // 1 is keeoing sub folder structures

dir = getDirectory("Choose a directory for aligned confocal files");

filepath0=getDirectory("temp");//C:\Users\??\AppData\Local\Temp\...C:\DOCUME~1\ADMINI~1\LOCALS~1\Temp\
filepath=filepath0+"MIP_batch.txt";

LF=10; TAB=9; swi=0; swi2=0; 
exi=File.exists(filepath);
List.clear();

if(exi==1){
	s1 = File.openAsRawString(filepath);
	swin=0;
	swi2n=-1;
	
	n = lengthOf(s1);
	String.resetBuffer;
	for (si=0; si<n; si++) {
		c = charCodeAt(s1, si);
		
		if(c==10){
			swi=swi+1;
			swin=swin+1;
			swi2n=swi-1;
		}
		
		if(swi==swin){
			if(swi2==swi2n){
				String.resetBuffer;
				swi2=swi;
			}
			if (c>=32 && c<=127)
			String.append(fromCharCode(c));
		}
		if(swi==0){
			exporttype = String.buffer;
		}else if(swi==1){
			subfolderS = String.buffer;
		}else if(swi==2){
			colorcodingS = String.buffer;
		}else if(swi==3){
			CLAHES = String.buffer;
		}else if(swi==4){
			AutoBR = String.buffer;
		}else if(swi==5){
			totalblock = String.buffer;
		}else if(swi==6){
			blockposition = String.buffer;
		}else if(swi==7){
			blockON = String.buffer;
		}else if(swi==8){
			desiredmean = String.buffer;
		}else if(swi==9){
			savestring = String.buffer;
		} //swi==0
	}
	File.saveString(exporttype+"\n"+subfolderS+"\n"+colorcodingS+"\n"+CLAHES+"\n"+AutoBR+"\n"+totalblock+"\n"+blockposition+"\n"+blockON+"\n"+desiredmean+"\n"+savestring, filepath);
}
if(exi==0){
	exporttype="1ch MIP";
	subfolderS=false;
	colorcodingS=false;
	CLAHES=false;
	AutoBR=false;
	blockposition=1;
	totalblock=3;
	blockON=false;
	desiredmean=130;
	savestring="Save in same folder";
//	JPGon=false;
}

Dialog.create("Batch processing of 3D files conversion");
//item0=newArray("1ch MIP", "2ch MIP", "3D tiff", "Both-MIP & 3Dtif");
//Dialog.addRadioButtonGroup("Export type", item0, 1, 4, exporttype); 
Dialog.addCheckbox("Include sub-folder", subfolderS);
Dialog.addCheckbox("Depth Color coding MIP", colorcodingS);
Dialog.addCheckbox("Automatic Brightness adjustment", AutoBR);
Dialog.addCheckbox("Enhance contrast CLAHE", CLAHES);
Dialog.addCheckbox("Block Mode", blockON);
//Dialog.addCheckbox("LZW compression", JPGon);

item2=newArray("Save in same folder", "Choose directory");
Dialog.addRadioButtonGroup("Export type", item2, 1, 2, savestring); 

Dialog.show();
//exporttype = Dialog.getRadioButton();
subfolder=Dialog.getCheckbox();
colorcoding=Dialog.getCheckbox();
AutoBRV=Dialog.getCheckbox();
CLAHE=Dialog.getCheckbox();
blockmode=Dialog.getCheckbox();
savestring = Dialog.getRadioButton();
//JPG=Dialog.getCheckbox();

list = getFileList(dir);
Array.sort(list);
startn=0;
endn=list.length;
blockON=false;
dirCOLOR=0;
if(savestring=="Choose directory"){
	dirCOLOR= getDirectory("Choose a directory for Color MIP SAVE");
	savemethod=1;
}
if(savestring=="Save in same folder")
savemethod=0;

if(blockmode==1){
	Dialog.create("Block separation for file number");
	Dialog.addNumber("Handling block", blockposition, 0, 0, " /Total block"); //0
	Dialog.addNumber("Total block number 1-10", totalblock, 0, 0, ""); //0
	Dialog.show();
	
	blockposition=Dialog.getNumber();
	totalblock=Dialog.getNumber();
	
	blocksize=(list.length/totalblock);
	blocksize=round(blocksize);
	startn=blocksize*(blockposition-1);
	endn=startn+blocksize;
	
	if(blockposition==totalblock)
	endn=list.length;
	
	blockON=true;
}

if(subfolder==1)
subfolderS=true;

if(colorcoding==1)
colorcodingS=true;

if(CLAHE==1)
CLAHES=true;

if(AutoBRV==1)
AutoBR=true;

if(AutoBRV==0)
AutoBR=false;

if(subfolder==0)
subfolderS=false;

if(colorcoding==0)
colorcodingS=false;

if(CLAHE==0)
CLAHES=false;

if(AutoBRV==1){
	Dialog.create("Desired mean value for Auto-Brightness");
	Dialog.addNumber("Desired mean value for Auto-Brightness /255", desiredmean);
	Dialog.show();
	desiredmean=Dialog.getNumber();
	print("Desired mean; "+desiredmean);
}

File.saveString(exporttype+"\n"+subfolderS+"\n"+colorcodingS+"\n"+CLAHES+"\n"+AutoBR+"\n"+totalblock+"\n"+blockposition+"\n"+blockON+"\n"+desiredmean+"\n"+savestring, filepath);

myDir = 0; myDirT = 0; myDirCLAHE = 0; myDir2Co = 0;
//if(exporttype=="3D tiff" || exporttype=="Both-MIP & 3Dtif"){
//	myDirT = dir+File.separator+"TIFF_Files"+File.separator;
//	File.makeDirectory(myDirT);
//}

firsttime=0;
firsttime1ch=0;
nc82=0;
neuronimg=0;
myDir2=0;
myDirCLAHE=0;
myDir2Co=0;
myDir=0;
for (i=startn; i<endn; i++){
	progress=i/list.length;
	showProgress(progress);
	path = dir+list[i];
	
	mipbatch=newArray(list[i], path, 1, dirCOLOR, endn, i, dir, startn, firsttime, firsttime1ch, AutoBRV, colorcoding, desiredmean, savemethod, CLAHE, neuronimg, nc82,myDir2,myDirCLAHE,myDir2Co, myDir);
	
	if (endsWith(list[i], "/")){
		if(subfolder==1){
			
			if(keepsubst==1){
				myDir0 = dirCOLOR+File.separator+list[i];
				File.makeDirectory(myDir0);
				dirCOLOR=myDir0;
			}
			
			print(subfolder);

			listsub = getFileList(dir+list[i]);
			Array.sort(listsub);
			for (ii=0; ii<listsub.length; ii++){
					
				path2 = path+listsub[ii];
				mipbatch=newArray(listsub[ii], path2, 1, dirCOLOR, endn, i, dir, startn, firsttime, firsttime1ch, AutoBRV, colorcoding, desiredmean, savemethod, CLAHE, neuronimg, nc82,myDir2,myDirCLAHE,myDir2Co, myDir);
				mipfunction(mipbatch);
				firsttime=mipbatch[8];
				firsttime1ch=mipbatch[9];
				neuronimg=mipbatch[15];
				nc82=mipbatch[16];
				myDir2=mipbatch[17];
				myDirCLAHE=mipbatch[18];
				myDir2Co=mipbatch[19];
				myDir=mipbatch[20];
			}
		
		}
	}else{
		mipfunction(mipbatch);
		firsttime=mipbatch[8];
		firsttime1ch=mipbatch[9];
		neuronimg=mipbatch[15];
		nc82=mipbatch[16];
		myDir2=mipbatch[17];
		myDirCLAHE=mipbatch[18];
		myDir2Co=mipbatch[19];
		myDir=mipbatch[20];
	}
}
/////////Function//////////////////////////////////////////////////////////////////
function mipfunction(mipbatch) { 
	listP=mipbatch[0];
	path=mipbatch[1];
	
	dirCOLOR=mipbatch[3];
	endn=mipbatch[4];
	i=mipbatch[5];
	dir=mipbatch[6];
	startn=mipbatch[7];
	firsttime=mipbatch[8];
	firsttime1ch=mipbatch[9];
	AutoBRV=mipbatch[10];
	colorcoding=mipbatch[11];
	desiredmean=mipbatch[12];
	savemethod=mipbatch[13];
	CLAHE=mipbatch[14];
	neuronimg=mipbatch[15];
	nc82=mipbatch[16];
	myDir2=mipbatch[17];
	myDirCLAHE=mipbatch[18];
	myDir2Co=mipbatch[19];
	
	dotIndex = -1;
	dotIndexAM = -1;
	dotIndextif = -1;
	dotIndexTIFF = -1;
	dotIndexLSM = -1;
	dotIndexV3 = -1;
	dotIndexMha= -1;
	
	files=files+1;
	
	dotIndexMha = lastIndexOf(listP, "mha");
	dotIndexV3 = lastIndexOf(listP, "v3dpbd");
	dotIndexLSM = lastIndexOf(listP, "lsm");
	dotIndex = lastIndexOf(listP, "nrrd");
	dotIndexAM = lastIndexOf(listP, "am");
	dotIndextif = lastIndexOf(listP, "tif");
	dotIndexTIFF = lastIndexOf(listP, "TIFF");
	
	if(dotIndextif==-1 && dotIndexTIFF==-1 && dotIndex==-1 && dotIndexAM==-1 && dotIndexLSM==-1 && dotIndexMha==-1){
	}else{
		
		if(compCC==0){// if not compressed
			if(dotIndex>-1 || dotIndexAM>-1){
				run("Bio-Formats Importer", "open="+path+" autoscale color_mode=Default view=[Standard ImageJ] stack_order=Default");
			}
		}
		if(dotIndextif>-1 || dotIndexTIFF>-1 || compCC==1 || dotIndexLSM>-1 || dotIndexV3>-1 || dotIndexMha>-1){
			open(path);// for tif, comp nrrd, lsm", am, v3dpbd, mha
		}
		print(listP+"	 ;	 "+i+" / "+endn);
		//		run("Close", "Exception");
		bitd=bitDepth();
		totalslice=nSlices();
		origi=getTitle();
		getDimensions(width, height, channels, slices, frames);

		dotIndex = lastIndexOf(origi, ".");
		if (dotIndex!=-1);
		origiMIP = substring(origi, 0, dotIndex); // remove extension
		
/////////////////////////////CH=2//////////////////////////////////////////////////
		if(channels==2){
			
			if(firsttime==1)
			run("Split Channels");
			
			if(firsttime==0){//creating directory
				firsttime=1;
				if(CLAHE==0){
					if(savemethod==1)
					myDir2 = dirCOLOR;
					
					if(savemethod==1){
						myDir2 = dir+File.separator+"2ch_MIP_Files"+File.separator;
						File.makeDirectory(myDir2);
					}
				}//if(CLAHE==0){
				
				if(CLAHE==1){
					if(savemethod==1)
					myDirCLAHE = dirCOLOR;
					
					if(AutoBRV==1){
						if(savemethod==0)
						myDirCLAHE = dir+File.separator+"2ch_CLAHE_MIP_"+desiredmean+"_mean_adjusted"+File.separator;
					}//if(AutoBRV==1){
					
					if(AutoBRV==0){
						if(savemethod==0)
						myDirCLAHE = dir+File.separator+"2ch_CLAHE_MIP"+File.separator;
					}//if(AutoBRV==0){
					if(savemethod==0)
					File.makeDirectory(myDirCLAHE);
				}//if(CLAHE==1){
				
				if(colorcoding==1){
					if(savemethod==1)
					myDir2Co = dirCOLOR;
					
					if(AutoBRV==1){
						if(savemethod==0)
						myDir2Co = dir+File.separator+"Color_Depth_MIP_"+desiredmean+"_mean_adjusted"+File.separator;
					}//if(AutoBRV==1){
					
					if(AutoBRV==0){
						if(savemethod==0)
						myDir2Co = dir+File.separator+"Color_Depth_MIP"+File.separator;
					}//if(AutoBRV==0){
					
					if(savemethod==0)
					File.makeDirectory(myDir2Co);
				}//if(colorcoding==1){
				
				setBatchMode(false);
				updateDisplay();
				run("Split Channels");
			
				waitForUser("Choose neuron channel on Top, nc82 window for bottom");
				neuronimg=getTitle();
				
				setBatchMode(true);
				if(neuronimg=="C1-"+origi){
					neuronimg="C1-";
					nc82="C2-";
				}//if(neuronimg=="C1-"+origi){
				if(neuronimg=="C2-"+origi){
					neuronimg="C2-";
					nc82="C1-";
				}//if(neuronimg=="C2-"+origi){
			}//if(firsttime==0){//creating directory
			
			selectWindow(nc82+origi);//Red nc82
	//		run("Z Project...", "projection=[Max Intensity]");
	//		if(bitd==16)
	//		setMinAndMax(0, 4095);
			
	//		selectWindow(nc82+origi);
			close();
			
			selectWindow(neuronimg+origi);//Green signal
			
			if(bitd==16)
			setMinAndMax(0, 4095);
			
			run("Mean Thresholding", "-=30 thresholding=Subtraction");//new plugins
			run("Z Project...", "projection=[Max Intensity]");
			if(bitd==16)
			setMinAndMax(0, 4095);
			
			if(AutoBRV==1){
				selectWindow("MAX_"+neuronimg+origi);
				briadj=newArray(desiredmean, 0, 0, 0);
				autobradjustment(briadj);
				applyV=briadj[2];
				sigsize=briadj[1];
				sigsizethre=briadj[3];
				sigsizethre=round(sigsizethre);
				sigsize=round(sigsize);
				
				selectWindow("MAX_"+neuronimg+origi);
				close();
				if(applyV<15)
				applyV=30;
				
		//		if(bitd==8){
		//			if(applyV<255){
		//				setMinAndMax(0, applyV);
		//				run("Apply LUT");
		//			}
		//		}
		//		if(bitd==16){
		//			if(applyV<4095)
		//			setMinAndMax(0, applyV);
		//			run("8-bit");
	//			}//if(bitd==16){
			}//	if(AutoBRV==1){
			
	//		selectWindow("MAX_"+neuronimg+origi);
			
	//		if(CLAHE==1){
	//			run("Enhance Local Contrast (CLAHE)", "blocksize=127 histogram=256 maximum=1.5 mask=*None*");
	//		}

	//		run("Merge Channels...", "c1=MAX_"+nc82+origi+" c2=MAX_"+neuronimg+origi+" c3=MAX_"+nc82+origi+"");
	//		selectWindow("RGB");
	//		if(CLAHE==1)
	//		save(myDirCLAHE+origiMIP+"_"+applyV+"_s"+sigsize+".tif");
			
	//		if(CLAHE==0)
	//		save(myDir2+origiMIP+"_"+applyV+"_s"+sigsize+".tif");
			
	//		close();//RGB MIP
			
			if(colorcoding==1){
				selectWindow(neuronimg+origi);
				
				if(AutoBRV==1){
					
					if(bitd==8){
						if(applyV<255){
							setMinAndMax(0, applyV);
							run("Apply LUT", "stack");
						}
					}//if(bitd==8){
					if(bitd==16){
						if(applyV<4095){
							setMinAndMax(0, applyV);
						}
						run("8-bit");
					}//if(bitd==16){
				}//	if(AutoBRV==1){
				rename("C1origi.tif");
				
				getDimensions(width2, height2, channels2, slices, frames);
				addingslices=slices/10;
				addingslices=round(addingslices);

				for(GG=1; GG<=addingslices; GG++){
					setSlice(nSlices);
					run("Add Slice");
				}

				for(GG=1; GG<=addingslices; GG++){
					setSlice(1);
					run("Add Slice");
				}
				
		//		newImage("Untitled.tif", "8-bit black", width2, height2, addingslices);
		//		newImage("Untitled2.tif", "8-bit black", width2, height2, addingslices);

		//		run("Concatenate No macro", "  title=[Concatenated Stacks.tif] image_1=Untitled.tif image_2=C1origi.tif image_3=Untitled2.tif image_4=[-- None --]");
				
				TimeLapseColorCoder(slices);
				
				selectWindow("color time scale");
				run("Select All");
				run("Copy");
				close();
				
				selectWindow("color.tif");
				makeRectangle(width-257, 1, 256, 48);
				run("Paste");
				
				if(AutoBRV==1){
					setFont("Arial", 20, " antialiased");
					setColor("white");
					if(applyV>99){
						if(bitd==8)
						drawString("Max: "+applyV+" /255", width-150, 78);
						
						if(bitd==16)
						drawString("Max: "+applyV+" /4095", width-150, 78);
					}
					if(applyV<100){
						if(bitd==8)
					drawString("Max: 0"+applyV+" /255", width-150, 78);
						if(bitd==16)
						drawString("Max: 0"+applyV+" /4095", width-150, 78);
					}
				}//	if(AutoBRV==1){
			
				run("Select All");
				setMetadata("Label", applyV);
		
				run("Enhance Local Contrast (CLAHE)", "blocksize=127 histogram=256 maximum=1.5 mask=*None*");
				save(myDir2Co+origiMIP+"_"+applyV+"_DSLT"+sigsize+"_thre"+sigsizethre+".tif");
				
				close();
				
			}//if(colorcoding==1){
			run("Close All");
		}//if(channels==2){
		
////1CH/////////////////////////////////////////////////////////////////
		if(channels==1){
		
//			if(colorcoding==0){
//				if(AutoBRV==1)
//				myDir = dir+File.separator+"1Ch_MIP_Files"+desiredmean+"_mean_adjusted"+File.separator;
//				if(AutoBRV==0)
//				myDir = dir+File.separator+"1Ch_MIP_Files"+File.separator;
//				if(firsttime1ch==0){
//					firsttime1ch=1;
//					File.makeDirectory(myDir);
	//			}
//			}
			if(colorcoding==1){
				if(savemethod==1)
				myDir2Co = dirCOLOR;
						
				if(savemethod==0){
					myDir2Co = dir+File.separator+"1ch_Color_Depth_MIP"+desiredmean+"_mean_adjusted"+File.separator;
					if(firsttime1ch==0){
						File.makeDirectory(myDir2Co);
						firsttime1ch=1;
					}
				}
			}//if(colorcoding==1){

			run("Mean Thresholding", "-=30 thresholding=Subtraction");//new plugins
			if(bitd==16)
			setMinAndMax(0, 4095);
			
			run("Z Project...", "projection=[Max Intensity]");
			rename("MIP.tif");
			if(bitd==16)
			setMinAndMax(0, 4095);
				
			if(AutoBRV==1){
				selectWindow("MIP.tif");
				briadj=newArray(desiredmean, 0, 0, 0);
				autobradjustment(briadj);
				applyV=briadj[2];
				sigsize=briadj[1];
				sigsizethre=briadj[3];
				sigsizethre=round(sigsizethre);
				sigsize=round(sigsize);
				
				if(applyV<15)
				applyV=30;
					
			}//	if(AutoBRV==1){
		//	if(colorcoding==0){
	//			selectWindow("MIP.tif");
				
		//		if(bitd==8){
		//			if(applyV<255){
		//				setMinAndMax(0, applyV);
		//				run("Apply LUT");
		//			}
		//		}//8
		//		if(bitd==16){
		//			if(applyV<4095)
		//			setMinAndMax(0, applyV);
		//			run("8-bit");
		//		}//if(bitd==16){
		//		setMetadata("Label", applyV);
		//		if(CLAHE==1){//&& colorcoding==0
		//			run("Enhance Local Contrast (CLAHE)", "blocksize=127 histogram=256 maximum=2 mask=*None*");
		//			save(myDir+origiMIP+"_"+applyV+"_s"+sigsize+".tif");
		//		}
		//		if(CLAHE==0)
		//		save(myDir+origiMIP+"_"+applyV+"_s"+sigsize+".tif");
				
				
	//		}//if(colorcoding==0){
			
			selectWindow("MIP.tif");
			close();//MIP.tif
			
			if(colorcoding==1){
				selectWindow(origi);
				rename("C1origi.tif");
				
				if(bitd==8){
					if(applyV<255){
						setMinAndMax(0, applyV);
						run("Apply LUT", "stack");
					}
				}
				if(bitd==16){
					if(applyV<4095)
					setMinAndMax(0, applyV);
					run("8-bit");
				}//if(bitd==16){
				
				getDimensions(width2, height2, channels2, slices, frames);
				addingslices=slices/10;
				addingslices=round(addingslices);

				for(GG=1; GG<=addingslices; GG++){
					setSlice(nSlices);
					run("Add Slice");
				}

				for(GG=1; GG<=addingslices; GG++){
					setSlice(1);
					run("Add Slice");
				}
				
		//		newImage("Untitled.tif", "8-bit black", width2, height2, addingslices);
		//		newImage("Untitled2.tif", "8-bit black", width2, height2, addingslices);
					
		//		run("Concatenate No macro", "  title=[Concatenated Stacks.tif] image_1=Untitled.tif image_2=C1origi.tif image_3=Untitled2.tif image_4=[-- None --]");
					
				TimeLapseColorCoder(slices);
									
				selectWindow("color time scale");
				run("Select All");
				run("Copy");
				close();
					
				selectWindow("color.tif");
				run("Properties...", "channels=1 slices=1 frames=1 unit=pixel pixel_width=1.0000 pixel_height=1.0000 voxel_depth=0 global");
	
				makeRectangle(width-257, 1, 256, 48);
				run("Paste");
					
				if(AutoBRV==1){
					setFont("Arial", 20, " antialiased");
					setColor("white");
					if(applyV>99){
						if(bitd==8)
						drawString("Max: "+applyV+" /255", width-150, 78);
						
						if(bitd==16)
						drawString("Max: "+applyV+" /4095", width-150, 78);
					}
					if(applyV<100){
						if(bitd==8)
						drawString("Max: 0"+applyV+" /255", width-150, 78);
						if(bitd==16)
						drawString("Max: 0"+applyV+" /255", width-150, 78);
					}
				}//if(AutoBRV==1){
				run("Select All");
				setMetadata("Label", applyV);
				if(CLAHE==1){
					run("Enhance Local Contrast (CLAHE)", "blocksize=127 histogram=256 maximum=2 mask=*None*");
					save(myDir2Co+origiMIP+"_"+applyV+"_DSLT"+sigsize+"_thre"+sigsizethre+".tif");
				}
			 if(CLAHE==0){
					save(myDir2Co+origiMIP+"_"+applyV+"_DSLT"+sigsize+"_thre"+sigsizethre+".tif");
		//			print(myDir1chColor);
				}
				close();
				
			//	selectWindow("Concatenated Stacks.tif");
			//	close();
			}//if(colorcoding==1){
			
		}//if(channels==1){

		run("Close All");
		mipbatch[8]=firsttime;
		mipbatch[9]=firsttime1ch;
		mipbatch[15]=neuronimg;
		mipbatch[16]=nc82;
		
		mipbatch[17]=myDir2;
		mipbatch[18]=myDirCLAHE;
		mipbatch[19]=myDir2Co;
		mipbatch[20]=myDir;
	}//if(dotIndextif==-1 && dotI
} //function mipfunction(mipbatch) { 
///////////////////////////////////////////////////////////////
function autobradjustment(briadj){
	if(autothre==1)//Fiji Original thresholding
	run("Duplicate...", "title=test.tif");
	
	origi2=getTitle();
	bitd=bitDepth();
	run("Properties...", "channels=1 slices=1 frames=1 unit=px pixel_width=1 pixel_height=1 voxel_depth=1");
	getDimensions(width2, height2, channels, slices, frames);
	totalpix=width2*height2;
	
	desiredmean=briadj[0];
	run("Select All");
	if(bitd==8){
		run("Copy");
	}
	
	if(bitd==16){
		setMinAndMax(0, 4095);
		run("Copy");
	}
	/////////////////////signal size measurement/////////////////////
	selectWindow(origi2);
	
	run("Duplicate...", "title=test2.tif");
	setAutoThreshold("Triangle dark");
	getThreshold(lower, upper);
	setThreshold(lower, 255);
	
	run("Convert to Mask", "method=Triangle background=Dark black");
	
	selectWindow("test2.tif");
	
	if(bitd==16)
	run("8-bit");
	
	run("Create Selection");
	getStatistics(areathre, mean, min, max, std, histogram);
	if(mean<200){
		selectWindow("test2.tif");
		run("Make Inverse");
	}
	getStatistics(areathre, mean, min, max, std, histogram);
	close();//test2.tif
	
	
	if(areathre/totalpix>0.4){

		selectWindow(origi2);
		
		run("Duplicate...", "title=test2.tif");
		setAutoThreshold("Moments dark");
		getThreshold(lower, upper);
		setThreshold(lower, 255);
		
		run("Convert to Mask", "method=Moments background=Dark black");
		
		selectWindow("test2.tif");
		
		if(bitd==16)
		run("8-bit");
		
		run("Create Selection");
		getStatistics(areathre, mean, min, max, std, histogram);
		if(mean<200){
			selectWindow("test2.tif");
			run("Make Inverse");
		}
		getStatistics(areathre, mean, min, max, std, histogram);
		close();//test2.tif
		
	}//if(area/totalpix>0.4){
	
	/////////////////////Fin signal size measurement/////////////////////
	
	selectWindow(origi2);
	if(autothre==1){//Fiji Original thresholding
		setAutoThreshold("Triangle dark");
		getThreshold(lower, upper);
		setThreshold(lower, 255);
	
		run("Convert to Mask", "method=Triangle background=Dark black");
		run("16-bit");
		run("Mask255 to 4095");
		
		makeRectangle(11, height2-100, 69, 43);
		getStatistics(area, mean, min, max, std, histogram);
		
		if(mean>200){
			run("Invert LUT");
			run("RGB Color");
			run("16-bit");
			run("Mask255 to 4095");
		}
		rename("test.tif");
	}//if(autothre==1){//Fiji Original thresholding
	
	if(autothre==0){//DSLT
		
		if(bitd==8)
		run("DSLT ", "radius_r_max=4 radius_r_min=2 radius_r_step=2 rotation=6 weight=16 filter=GAUSSIAN close=None noise=5px");
		
		if(bitd==16){
			run("DSLT ", "radius_r_max=5 radius_r_min=2 radius_r_step=3 rotation=6 weight=250 filter=GAUSSIAN close=None noise=5px");
			
			run("16-bit");
			run("Mask255 to 4095");
		}
		rename("test.tif");
	}//if(autothre==0){//DSLT
	
	selectWindow("test.tif");
	
	run("Duplicate...", "title=test2.tif");
	selectWindow("test2.tif");
	
	if(bitd==16)
	run("8-bit");
	
	run("Create Selection");
	getStatistics(area, mean, min, max, std, histogram);
	if(mean<200){
		selectWindow("test2.tif");
		run("Make Inverse");
	}
	getStatistics(area2, mean, min, max, std, histogram);
	close();//test2.tif
	
	
	if(area2/totalpix<0.05){// set DSLT more sensitive, too dim images
		selectWindow("test.tif");
		close();
		
		selectWindow(origi2);//MIP
		
		if(bitd==8){
			run("DSLT ", "radius_r_max=4 radius_r_min=2 radius_r_step=2 rotation=6 weight=3 filter=GAUSSIAN close=None noise=5px");
			getStatistics(area2, mean, min, max, std, histogram);
		}
		if(bitd==16){
			run("DSLT ", "radius_r_max=5 radius_r_min=2 radius_r_step=3 rotation=6 weight=50 filter=GAUSSIAN close=None noise=5px");
			
			run("Create Selection");
			getStatistics(area, mean, min, max, std, histogram);
			if(mean<200)
			run("Make Inverse");
			
			getStatistics(area2, mean, min, max, std, histogram);
			run("16-bit");
			run("Mask255 to 4095");
		}
		rename("test.tif");
		
	}//if(area2/totalpix<0.01){
	
	//////////////////////
	if(autothre==1){//Fiji Original thresholding
		if(area2/totalpix>0.4){
			selectWindow("test.tif");
			setSlice(1);
			run("Select All");
			run("Paste");
			
			if(bitd==16)
			setMinAndMax(0, 4095);
			
			setAutoThreshold("Moments dark");
			getThreshold(lower, upper);
			if(bitd==8)
			setThreshold(lower, 255);
			
			if(bitd==16)
			setThreshold(lower, 4095);
			
			run("Convert to Mask", "method=Moments background=Dark black");
	//		setBatchMode(false);
	//		updateDisplay();
			//				a
			if(bitd==16)
			run("8-bit");
			
			makeRectangle(11, height2-100, 69, 43);
			getStatistics(area, mean, min, max, std, histogram);
			
			if(mean>200){
				run("Invert LUT");
			}
		
			getStatistics(area, mean, min, max, std, histogram);
			if(mean<250)
			run("Make Inverse");
		}//if(area/totalpix>0.3){
	}//	if(autothre==1){//Fiji Original thresholding
	
	selectWindow(origi2);//MIP
	rename("MIP.tif");

	run("Mask Brightness Measure", "mask=test.tif data=MIP.tif desired="+desiredmean+"");
//	setBatchMode("exit and display");
//	a
	
	applyV=getTitle();
	applyV=round(applyV);

	if(bitd==8)
	applyV=255-applyV;
	
	if(bitd==16)
	applyV=4095-applyV;
	
	if(applyV==0){
		if(bitd==8)
		applyV=255;
		
		if(bitd==16)
		applyV=4095;
	}
	
	rename(origi2);

	selectWindow("test.tif");
	close();
	
	sigsize=area2/totalpix;
	if(sigsize==1)
	sigsize=0;
	
	sigsizethre=areathre/totalpix;
	if(sigsizethre==1)
	sigsizethre=0;
	
	print("Signal brightness; 	"+applyV+"	 Signal Size DSLT; 	"+sigsize+"	 Sig size threshold; 	"+sigsizethre);
	briadj[1]=(sigsize)*100;
	briadj[2]=applyV;
	briadj[3]=sigsizethre*100;
}
	
function TimeLapseColorCoder(slicesOri) {//"Time-Lapse Color Coder" 
	var Glut = "royal";	//default LUT
	var Gstartf = 1;var Gendf = 10;
	var GFrameColorScaleCheck = 1;
		
	Stack.getDimensions(ww, hh, channels, slices, frames);
	if (channels > 1)
	exit("Cannot color-code multi-channel images!");
		//swap slices and frames in case:
	if ((slices > 1) && (frames == 1)) {
		frames = slices;
		slices = 1;
		Stack.setDimensions(1, slices, frames);
		//	print("slices and frames swapped");
	}
	Gendf = frames;
	showDialog();
	if (Gstartf <1) Gstartf = 1;
	if (Gendf > frames) Gendf = frames;
	totalframes = Gendf - Gstartf + 1;
	calcslices = slices * totalframes;
	imgID = getImageID();
		
	newImage("colored", "RGB White", ww, hh, calcslices);
	//	print(frames+";"+slices);
	run("Stack to Hyperstack...", "order=xyczt(default) channels=1 slices="+ slices + " frames=" + totalframes + " display=Color");
		newimgID = getImageID();
		
		selectImage(imgID);
		run("Duplicate...", "duplicate");
	//	run("8-bit");
		imgID = getImageID();
		
		newImage("stamp", "8-bit White", 10, 10, 1);
		run(Glut);
		getLut(rA, gA, bA);
		close();
		nrA = newArray(256);
		ngA = newArray(256);
		nbA = newArray(256);
		
		newImage("temp", "8-bit White", ww, hh, 1);
		tempID = getImageID();
		
		for (i = 0; i < totalframes; i++) {
			colorscale = floor((256 / totalframes) * i);
			for (j = 0; j < 256; j++) {
				intensityfactor = j / 255;
				
				nrA[j] = round(rA[colorscale] * intensityfactor);
				ngA[j] = round(gA[colorscale] * intensityfactor);
				nbA[j] = round(bA[colorscale] * intensityfactor);
			}
			
			for (j = 0; j < slices; j++) {
			selectImage(imgID);//original image, duplicated
				Stack.setPosition(1, j + 1, i + Gstartf);
				run("Select All");
				run("Copy");
				
				selectImage(tempID);//single slice image for lut change
				run("Paste");
				setLut(nrA, ngA, nbA);
				run("RGB Color");
				run("Select All");
				run("Copy");
				run("8-bit");
				
				selectImage(newimgID);//hyper stack, color 3D stack
				Stack.setPosition(1, j + 1, i + 1);
				run("Select All");
				run("Paste");
			}
		}
		
	selectImage(tempID);
	close();
		
	selectImage(imgID);
	close();
	
	selectImage(newimgID);
	run("Stack to Hyperstack...", "order=xyctz channels=1 slices="+ totalframes + " frames=" + slices + " display=Color");
		//	setBatchMode("exit and display");
		//	a
	op = "start=1 stop=" + Gendf + " projection=[Max Intensity] all";
	run("Z Project...", op);
	if (slices > 1)
	run("Stack to Hyperstack...", "order=xyczt(default) channels=1 slices=" + slices+ " frames=1 display=Color");
	resultImageID = getImageID();
		
	selectImage(newimgID);
	close();
		
	selectImage(resultImageID);
		//setBatchMode("exit and display");
	rename("color.tif");
	if (GFrameColorScaleCheck)
	CreateScale(Glut, Gstartf, slicesOri);
}
	
	function showDialog() {
//		lutA = makeLUTsArray();
		
	//	Dialog.create("Color Code Settings");
//		Dialog.addChoice("LUT", lutA);
//	Dialog.addNumber("start frame", Gstartf);
//		Dialog.addNumber("end frame", Gendf);
//		Dialog.addCheckbox("Create Time Color Scale Bar", GFrameColorScaleCheck);
//		Dialog.show();
//		Glut = Dialog.getChoice();
//		Gstartf = Dialog.getNumber();
//		Gendf = Dialog.getNumber();
//		GFrameColorScaleCheck = Dialog.getCheckbox();
		
	Gendf =nSlices();
	Gstartf=1;
	Glut = "royal";
	GFrameColorScaleCheck=1;
}
	
function CreateScale(lutstr, beginf, endf){
	ww = 256;
	hh = 32;
	newImage("color time scale", "8-bit White", ww, hh, 1);
	for (j = 0; j < hh; j++) {
		for (i = 0; i < ww; i++) {
			setPixel(i, j, i);
		}
	}
	
	makeRectangle(25, 0, 204, 32);
	run("Crop");
	
	run(lutstr);
	run("RGB Color");
	op = "width=" + ww + " height=" + (hh + 16) + " position=Top-Center zero";
	run("Canvas Size...", op);
		setFont("SansSerif", 12, "antiliased");
	run("Colors...", "foreground=white background=black selection=yellow");
	drawString("Slices", round(ww / 2) - 12, hh + 16);
	drawString(leftPad(beginf, 3), 24, hh + 16);
	drawString(leftPad(endf, 3), ww - 50, hh + 16);
		}
	
function leftPad(n, width) {
	s = "" + n;
	while (lengthOf(s) < width)
	s = "0" + s;
	return s;
}

"done"
