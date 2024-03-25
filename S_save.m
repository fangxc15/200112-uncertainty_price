Folderpath = ['Resultcase' num2str(nnode)];
mkdir(Folderpath)
if exist('origin_reserve') && origin_reserve == 1
    filename = ['Method' num2str(methodchoose) '_originR'];
else
    filename = ['Method' num2str(methodchoose) '_Allocate' num2str(allocatestrategy)];
    if exist('stdrange')
        filename = [filename '_Std' num2str(stdrange)];
    end
    if exist('Ksig')
        filename = [filename '_Ksig' num2str(Ksig)];
    end
end
filename = [filename '_' Psheet Dsheet];
savetime =  datestr(datetime('now'),30);   
savepara = ['.\' Folderpath '\' filename savetime '.mat'];
save(savepara);

