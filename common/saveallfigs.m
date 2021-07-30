function saveallfigs(figfile)
%SAVEALLFIGS Save all open figures to zip file
figfile=regexprep(string(figfile),"\.zip$",""); figfile=figfile+".zip";
tempdir = 'tempfigs' ;
mkdir('.',tempdir);
FolderName = tempdir;   % Your destination folder
FigList = findobj(allchild(0), 'flat', 'Type', 'figure');
for iFig = 1:length(FigList)
  FigHandle = FigList(iFig);
  FigName   = string(FigList(iFig).Number) + "_" + string(FigList(iFig).Name);
  set(0, 'CurrentFigure', FigHandle);
  savefig(fullfile(FolderName, FigName+".fig"));
end
zip(figfile,'*',tempdir);
rmdir(tempdir,'s');