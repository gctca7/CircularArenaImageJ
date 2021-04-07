//dirResults ="X:\\Yoshi\\Registration\\Results\\";
dir= getDirectory("Image");
MaskTitle =getTitle();
MaskTitle = substring(MaskTitle, 0, lengthOf(MaskTitle)-4);
SliceTitle= getMetadata("Label");
dirSave = dir + MaskTitle +"\\";
dirSaveTitle = dirSave + SliceTitle;
if(File.exists(dirSave) !=1){
File.makeDirectory(dirSave);
}
run("Duplicate...", " ");
saveAs("Jpeg",dirSaveTitle);
close();
