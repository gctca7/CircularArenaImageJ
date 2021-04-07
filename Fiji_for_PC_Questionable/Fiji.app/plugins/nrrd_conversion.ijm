


dir=getDirectory("Choose a Directory for VNC nrrd");

String.resetBuffer;
n3 = lengthOf(dir);
for (si=0; si<n3; si++) {
	c = charCodeAt(dir, si);
	if(c==32){// if there is a space
		print("There is a space, please eliminate the space from entire saving path.");
		exit();
	}
}//	for (si=0; si<n3; si++) {
String.resetBuffer;
blockON=false;

filepath0=getDirectory("temp");//C:\Users\??\AppData\Local\Temp\...C:\DOCUME~1\ADMINI~1\LOCALS~1\Temp\
filepath=filepath0+"nrrd_batch.txt";

Zsize=0.38;
XYsize=0.18;
blockposition=1;
totalblock=3; unsharpStr=true; dupCheck=true; compress=true;

LF=10; TAB=9; swi=0; swi2=0; testline=0;
exi=File.exists(filepath);
List.clear();

if(exi==1){
	s1 = File.openAsRawString(filepath);
	swin=0;
	swi2n=-1;
	
	n = lengthOf(s1);
	String.resetBuffer;
	for (testnum=0; testnum<n; testnum++) {
		enter = charCodeAt(s1, testnum);
		
		if(enter==10)
		testline=testline+1;//line number
	}
	
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
			XYsize = String.buffer;
		}else if(swi==1 && swi<=testline){
			Zsize = String.buffer;
		}else if(swi==2 && swi<=testline){
			blockON = String.buffer;
		}else if(swi==3 && swi<=testline){
			blockposition=String.buffer;
		}else if(swi==4 && swi<=testline){
			totalblock=String.buffer;
		}else if(swi==5 && swi<=testline){
			unsharpStr = String.buffer;
		}else if(swi==6 && swi<=testline){
			dupCheck = String.buffer;
		}else if(swi==7 && swi<=testline){
			compress = String.buffer;
		}
	}
}

myDir0= getDirectory("Choose a directory for Color Nrrd SAVE");


Dialog.create("Batch processing of .nrrd conversion");

Dialog.addNumber("XY size per a voxel", XYsize,4,6, " micron");//Dialog.addNumber(label, default, decimalPlaces, columns, units)
Dialog.addNumber("Z size per a voxel", Zsize,4,6, " micron");
Dialog.addCheckbox("Block Mode", blockON);
Dialog.addCheckbox("Unsharp mask", unsharpStr);
Dialog.addCheckbox("Duplication check & skip", dupCheck);
Dialog.addCheckbox("Compressed nrrd", compress);

Dialog.show();

XYsize=Dialog.getNumber();//MIP starting slice
Zsize=Dialog.getNumber();//MIP ending slice
blockmode=Dialog.getCheckbox();//block mode for larger number of files
unsharp=Dialog.getCheckbox();
dupCheckNo=Dialog.getCheckbox();
compressNo=Dialog.getCheckbox();

unsharpStr=false;
if(unsharp==1)
unsharpStr=true;

dupCheck=false;
if(dupCheckNo==1)
dupCheck=true;

compress=false;
if(compressNo==1)
compress=true;

setBatchMode(true);
preTruName=0;
list = getFileList(dir);
Array.sort(list);

savelist = getFileList(myDir0);
Array.sort(savelist);

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
}else{
startn=0;
endn=list.length;
	
}
File.saveString(XYsize+"\n"+Zsize+"\n"+blockON+"\n"+blockposition+"\n"+totalblock+"\n"+unsharpStr+"\n"+dupCheck+"\n"+compress, filepath);

print("");
print(dir);
print("voxel size XY; "+XYsize+"  Z; "+Zsize);

for(i=startn; i<endn; i++){
	call("java.lang.System.gc");
	path=dir+list[i];
	
	dotIndextif = -1;
	dotIndextif = lastIndexOf(list[i], ".tif");

	dotIndexmha = -1;
	dotIndexmha = lastIndexOf(list[i], ".mha");
	
	dotIndexLSM = -1;
	dotIndexLSM = lastIndexOf(list[i], ".lsm");
	
	dotIndexZip = -1;
	dotIndexZip = lastIndexOf(list[i], ".zip");
	
	dotIndexNrrd = -1;
	dotIndexNrrd = lastIndexOf(list[i], ".nrrd");
	
	dotIndexFile = -1;
	dotIndexFile = lastIndexOf(list[i], "/");
	
	dotIndexV3 = -1;
	dotIndexV3 = lastIndexOf(list[i], ".v3dpbd");
	
	dotIndex = -1;
	dotIndex = lastIndexOf(list[i], ".");
	
	if(dotIndexFile==-1){
		if(dotIndextif>-1 || dotIndexLSM>-1 || dotIndexV3>-1 || dotIndexZip>-1  || dotIndexmha>-1 || dotIndexNrrd>-1){
			
			truName=substring(list[i], 0, dotIndex);
			
			duplication=0;
			
			if(dupCheck){
	//// duplication check///////////
				for(Dupcheck=0; Dupcheck<savelist.length; Dupcheck++){
					previousFilesNrrd=-1;
					previousFilesNrrd=lastIndexOf(savelist[Dupcheck], ".nrrd");
					
					if(previousFilesNrrd!=-1){
						PosiOrNot=-1;
						PosiOrNot=indexOf(savelist[Dupcheck], truName);
						
						if(PosiOrNot!=-1)
						duplication=1;
					}
				}
			}//if(dupCheck){
			
			if(duplication==0){
				open(path);
				print(list[i]+"  ; "+i+1+" / "+list.length);
				
				
				
				bitd=bitDepth();
				getDimensions(width, height, channels, slices, frames);
				
				if(bitd==24 || channels>1){
					run("Split Channels");//C2 is nc82
					titlelist=getList("image.titles");
					
					for(nimage=0; nimage<titlelist.length; nimage++){
						selectWindow(titlelist[nimage]);
						run("Properties...", "channels=1 slices="+nSlices+" frames=1 unit=micron pixel_width="+XYsize+" pixel_height="+XYsize+" voxel_depth="+Zsize+"");
						
						if(unsharp==1)
						run("Unsharp Mask...", "radius=1 mask=0.35 stack");
						
						if(compress)
						run("Nrrd Writer", "compressed nrrd="+myDir0+truName+"_"+nimage+1+".nrrd");
						else
						run("Nrrd Writer", "nrrd="+myDir0+truName+"_"+nimage+1+".nrrd");
						
						close();
					}
				}else{
					run("Properties...", "channels=1 slices="+nSlices+" frames=1 unit=micron pixel_width="+XYsize+" pixel_height="+XYsize+" voxel_depth="+Zsize+"");
					
					if(unsharp==1)
					run("Unsharp Mask...", "radius=1 mask=0.35 stack");
					
					if(compress)
					run("Nrrd Writer", "compressed nrrd="+myDir0+truName+".nrrd");
					else
					run("Nrrd Writer", "nrrd="+myDir0+truName+".nrrd");
				}
				run("Close All");
			}else{//if(duplication==0){
				print("Already nrrd exist; "+list[i]);
			}
		}
	}
}
"Done";