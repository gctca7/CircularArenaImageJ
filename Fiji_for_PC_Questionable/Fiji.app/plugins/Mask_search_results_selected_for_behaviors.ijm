dirResults ="X:\\Yoshi\\Registration\\Results\\Behaviors\\";
SliceTitle= getMetadata("Label");
dirSaveTitle = dirResults + SliceTitle;
run("Duplicate...", " ");
saveAs("Jpeg",dirSaveTitle);
close();
run("Delete Slice");