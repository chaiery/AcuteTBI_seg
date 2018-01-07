path='X:\ProTECT III PUD\Images\';
folderN=dir(path);
subj=[];
for i = 4 : length(folderN)
    Sdir = dir([path folderN(i).name '\']);
    for j = 3 : length(Sdir)
        if sum(ismember('MR',Sdir(j).name))==2
            subj=[subj;str2num(folderN(i).name)];
        end
    end
end
k=1;