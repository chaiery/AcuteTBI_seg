
dirName = 'Y:\CIREN data\Dicom_download\';

fl = getAllFiles(dirName,0);
   
final = zeros(numel(fl),5);

f = figure;

for i = 1154:25:numel(fl)
ban_split = strsplit(fl{i,1},'\');
final(i,2) = str2double(ban_split{end-1});
if strcmp(ban_split{end-2},'Dicom_download')==0
    final(i,1) = str2double(ban_split{end-2});
end
figure(f), 
for j=1:25
subplot(5,5,j),imshow(dicomread(fl{i+j-1}),[])
end
choice = questdlg('Type of image', ...
	num2str(i), ...
	'1','2','3','2');
% Handle response
switch choice
    case '1'
        final(i,3) = 1;
    case '2'
        final(i,4) = 1;
    case '3'
        final(i,5) = 1;
end
end


% 1=Brain
% 2=Abdomen
% 3=Pelvis
% 4=Spine