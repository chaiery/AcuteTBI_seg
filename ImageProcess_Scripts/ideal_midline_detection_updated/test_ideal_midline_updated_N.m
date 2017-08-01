function selectedImageList = test_ideal_midline_updated_N(inputDir, outputDir)

imageDirRoot = inputDir
imageDirSaveRoot = outputDir

imStru = [];
% imStru.img_Mattress = img_Mattress;
% imStru.SliceThickness = info.SliceThickness;
% imStru.PixelSpacing = info.PixelSpacing;
%  set the depth of slices

% initial some value of imStrut
% imStru.SliceThickness = 4.5;
% imStru.PixelSpacing = 0.46875;
% imStru.boneThreshold = 250; % default for jpg format

% set jpg format or dicom format
isDecFormat = false;
if isDecFormat
    imStru.boneThreshold = 500;
    imStru.isDecFormat = true;
else
    imStru.boneThreshold = 250;
    imStru.isDecFormat = false;
end
   
save_uncrack_Dir = 'SSAone_1uncrack';
save_skullArea_Dir = 'SSAone_2skullArea';
save_convexity_Dir = 'SSAone_3convexity';
save_VFM_Dir = 'SSAone_4VFM';
save_WFM1_Dir = 'SSAone_5WFM'; % roughly marked the order
save_ideal_Dir = 'dir_ideal'; %
save_ideal_color_Dir = 'dir_ideal_color'; %

save_EF_Dir = 'EF';

    
%% directory operations
% deal with Directory to open and save
fullImageDirRoot = imageDirRoot
% deal with the image in this folder (fullImageDirRoot)
fullSaveDir = imageDirSaveRoot
fullSaveDir_save_uncrack_Dir   = strcat(fullSaveDir , '/' , save_uncrack_Dir);
fullSaveDir_save_skullArea_Dir = strcat(fullSaveDir , '/' , save_skullArea_Dir);
fullSaveDir_save_convexity_Dir = strcat(fullSaveDir , '/' , save_convexity_Dir);
fullSaveDir_save_VFM_Dir = strcat(fullSaveDir , '/' , save_VFM_Dir);
fullSaveDir_save_WFM1_Dir = strcat(fullSaveDir , '/' , save_WFM1_Dir);
% fullSaveDir_save_WFM2_Dir = strcat(fullSaveDir , '/' , save_WFM2_Dir);
fullSaveDir_save_ideal_Dir = strcat(fullSaveDir , '/' , save_ideal_Dir);
fullSaveDir_save_ideal_clolr_Dir = strcat(fullSaveDir , '/' , save_ideal_color_Dir);

% eclipse fitting
fullSaveDir_save_EF_Dir = strcat(fullSaveDir , '/' , save_EF_Dir);

%
if ~exist(fullSaveDir_save_uncrack_Dir,'dir')
    mkdir(fullSaveDir_save_uncrack_Dir);
end
if ~exist(fullSaveDir_save_skullArea_Dir,'dir')
    mkdir(fullSaveDir_save_skullArea_Dir);
end
if ~exist(fullSaveDir_save_convexity_Dir,'dir')
    mkdir(fullSaveDir_save_convexity_Dir);
end
if ~exist(fullSaveDir_save_VFM_Dir,'dir')
    mkdir(fullSaveDir_save_VFM_Dir);
end
if ~exist(fullSaveDir_save_WFM1_Dir,'dir')
    mkdir(fullSaveDir_save_WFM1_Dir);
end
%     if ~exist(fullSaveDir_save_WFM2_Dir,'dir')
%         mkdir(fullSaveDir_save_WFM2_Dir);
%     end
if ~exist(fullSaveDir_save_ideal_Dir,'dir')
    mkdir(fullSaveDir_save_ideal_Dir);
end
if ~exist(fullSaveDir_save_ideal_clolr_Dir,'dir')
    mkdir(fullSaveDir_save_ideal_clolr_Dir);
end
if ~exist(fullSaveDir_save_EF_Dir,'dir')
    mkdir(fullSaveDir_save_EF_Dir);
end    


%% deal with every patient

% get file name list
% tmpFilenameList = dir(fullImageDirRoot);
% do loop for every fullImageDirRoot, that is every patient.
%  deal with one patient.
%     ( tmpFilename = tmpFilenameList.name;
%       imFilePathAndName = '';
%       imFilePathAndName = strcat(fullImageDirRoot, tmpFilename);
%       img_Mattress = imread(imFilePathAndName); )
%
% end loop
%  copy one patient files to related dirs. Then print results.
% end outer loop
%


if isDecFormat
    imgList = dir(strcat(fullImageDirRoot, '/', '*.dcm'));
else
    imgList = dir(strcat(fullImageDirRoot, '/', '*.jpg'));
end

lenList = length(imgList);

if lenList == 0
    imgList = dir(strcat(fullImageDirRoot, '/', '*.png'));
    lenList = length(imgList);
end

fprintf('--------********--------******** \r\n');
fprintf('The patient %s''s original list length is : %d . \r\n', fullImageDirRoot ,lenList);

imFilePathAndName_pre = '';
isFirstSliceOfFirstPerson = true;
person_postion = 0;
stru = '';
stru_good = '';
person_num = 1;

skullAreaVec = [];
convexityVec = [];

goodperson_postion = 0;
for i_img = 1: lenList
    person_postion = person_postion + 1;
    imgname = imgList(i_img).name;

    if isDecFormat
        in = strfind(imgname,'.dcm');
    else
        in = strfind(imgname,'.jpg');
    end

    firstPartOfFilename = imgname(1:in-1);
    imgnameWithoutExtendName = firstPartOfFilename;

    %imFilePathAndName = [imageDirRoot,imgname];
    imFilePathAndName = strcat(fullImageDirRoot, '/' , imgname);

    imgnameWithoutExtendName_pre = imgnameWithoutExtendName;

    % put into the first slice to the first person structure
    stru(person_postion).imFilePathAndName =  imFilePathAndName;
    stru(person_postion).imgnameWithoutExtendName =  imgnameWithoutExtendName;
    stru(person_postion).imgname =  imgname;
    stru(person_postion).imageDirSaveRoot =  imageDirSaveRoot;
    stru(person_postion).isDecFormat =  isDecFormat;
    stru(person_postion).imFilePathAndName =  imFilePathAndName;

    img_Mattress = imread(imFilePathAndName);
    if ndims(img_Mattress) ~=2
        img_Mattress = img_Mattress(:,:,1);
    end
    stru(person_postion).img_Mattress =  img_Mattress;

    fprintf('imgname  %s  \n' , imgname);
    rev = isCrashed(img_Mattress,250);
    if rev == 0
               img_Mattress_2d = uint8(img_Mattress(:,:,1));
        [innerbrain_mask, rev,nobrain] = getinnerbrainwhite(img_Mattress_2d,250);
    end
    if rev ~= 0
            %N start
              img_Mattress = closeFracture(img_Mattress);
%             mainbone_mask=getmainbonemaskwhite(img_Mattress,250);  
%             %to close fracture 
%             % baraye inke convex konim, input convhull column vector hast.
%             CC = bwconncomp(mainbone_mask);
%             numOfObjects=CC.NumObjects;
%             a=[]
%             for i= 1:numOfObjects
%             a=vertcat(a,CC.PixelIdxList{1,i});
%             end
%             siz= CC.ImageSize;
%             
%             [I,J] = ind2sub(siz,a);
%             k = convhull(I,J);
%             figure;plot(I(k),J(k),'r-',I,J,'b*');
% 
%             %to show
%             figure; imshow(img_Mattress)
%             for i=1:(length(k)-1)
%                 hold on
%                 line([J(k(i)),J(k(i+1))],[I(k(i)),I(k(i+1))],'color','r');
%             end
% 
%             %To apply points  to the CT-image
%             figure; imshow(mainbone_mask)
%             BW = roipoly(mainbone_mask,J(k),I(k)); %fills the whole area
%             BW2 = bwmorph(BW,'remove'); % The outer edge
%             BW2= bwmorph(BW2,'thicken');
%             % mainbone_mask(BW2)=1;
%             % mainbone_mask=imclose(mainbone_mask, ones(7,7));
%             img_Mattress(BW2)= 255;
            img_Mattress_2d = uint8(img_Mattress(:,:,1));
            [innerbrain_mask, rev, nobrain] = getinnerbrainwhite(img_Mattress_2d,250);

    end
            
          % N: end  

        %                 innerBrainImg = innerbrain_mask.*uint8(img_Mattress(:,:,1));

        % N: start
        skullArea = sum(sum(innerbrain_mask));
        if (nobrain==1)
        skullArea = 0;   
        end
        skullAreaVec = [skullAreaVec, skullArea]
        % N: end
        goodperson_postion = goodperson_postion + 1;
        stru_good(goodperson_postion).imFilePathAndName =  imFilePathAndName;
        stru_good(goodperson_postion).imgnameWithoutExtendName =  imgnameWithoutExtendName;
        stru_good(goodperson_postion).imgname =  imgname;
        stru_good(goodperson_postion).imageDirSaveRoot =  imageDirSaveRoot;
        stru_good(goodperson_postion).isDecFormat =  isDecFormat;
        stru_good(goodperson_postion).imFilePathAndName =  imFilePathAndName;
        stru_good(goodperson_postion).img_Mattress =  img_Mattress;



end

[skullArea_sort, skullArea_ind] = sort(skullAreaVec,'descend');
skullArea_num = length(skullArea_ind);

if skullArea_num ~= 0

    %% for uncracked skull image
    fprintf('\n---------------------------------------------------------------\n');
    %     fprintf('Person is : %s.  \nThe number of CT slices: %d \n'  , stru(1).imgnameWithoutExtendName(1:33),skullArea_num );

    fprintf(' The uncracked file lenList is : %d . \r\n',skullArea_num);
    for i_pos=1:skullArea_num
        fprintf(' filename:  %s  \n', stru_good(skullArea_ind(i_pos)).imgname);

        tmp_fn = strcat(fullSaveDir_save_uncrack_Dir, '/' ,stru_good(skullArea_ind(i_pos)).imgname);
        % tmp_fn = [fullSaveDir_save_uncrack_Dir,
        % stru_good(skullArea_ind(i_pos)).imgname]; % note: '/'
        imwrite(uint8(stru_good(skullArea_ind(i_pos)).img_Mattress),tmp_fn);
    end

    threshold_SkullArea_num = 9; % N: change 12 to 9
    % threshold_SkullArea_num = num;
    threshold_SkullArea_num = min(skullArea_num,threshold_SkullArea_num);

    %% for Top threshold_SkullArea_num image
    fprintf('\n---------------------------------------------------------------\n');
    fprintf(' The Top %d descently sorted Intracranial Area file List is : \r\n',threshold_SkullArea_num);
    for i_pos=1:skullArea_num
        if i_pos <= threshold_SkullArea_num
            fprintf('  sequence: %d  <--> filename:   %s <-->  Intracranial Area %4.3f\n', i_pos ,stru_good(skullArea_ind(i_pos)).imgname,skullArea_sort(i_pos));


            % tmp_fn = [fullSaveDir_save_skullArea_Dir, stru_good(skullArea_ind(i_pos)).imgname];
            tmp_fn = strcat(fullSaveDir_save_skullArea_Dir, '/' ,stru_good(skullArea_ind(i_pos)).imgname);
            imwrite(uint8(stru_good(skullArea_ind(i_pos)).img_Mattress),tmp_fn);
        end
    end

    %% for convexity_num skull image
    %dir(save_skullArea_Dir);
    if isDecFormat
        % imgListForConvexity = dir([fullSaveDir_save_skullArea_Dir, '/*.dcm']);
        imgListForConvexity = dir(strcat(fullSaveDir_save_skullArea_Dir,'/', '*.dcm'));
    else
        % imgListForConvexity = dir([fullSaveDir_save_skullArea_Dir, '/*.jpg']);
        imgListForConvexity = dir(strcat(fullSaveDir_save_skullArea_Dir,'/', '*.jpg'));
    end

    % caculate the convexityVec
    for i_pos=1:threshold_SkullArea_num
        % imStru.img_Mattress = ;

        % read?in?image:?img_Mattress
        imFilePathAndName = '';
        imFilePathAndName = strcat(fullSaveDir_save_skullArea_Dir, '/' ,imgListForConvexity(i_pos).name);
        img_Mattress = imread(imFilePathAndName);
        if ndims(img_Mattress) ~= 2
            img_Mattress = img_Mattress(:,:,1);
        end
        stru_good_convexity(i_pos).img_Mattress =  img_Mattress;
        stru_good_convexity(i_pos).boneThreshold = 250;
        stru_good_convexity(i_pos).imgname = imgListForConvexity(i_pos).name;

        outerBw = 0;
        innerBw = 0;
        imStru = stru_good_convexity(i_pos);
        [   stru_good_convexity(i_pos).bwSkullBone , ...\
            stru_good_convexity(i_pos).center , ...\
            stru_good_convexity(i_pos).rev] = getSkullBoneAndCenter(imStru);

        if stru_good_convexity(i_pos).rev == 0
            % segmentation of the brain tisure, suppose the skull is connected
            bwSkullBone = stru_good_convexity(i_pos).bwSkullBone;
            bwSkullBone2=1-bwSkullBone;
            label_img=bwlabel(bwSkullBone2);
            seg_outer=zeros(size(bwSkullBone));
            seg_outer(find(label_img==1))=1;
            seg_skull_out=1-seg_outer;
            bw1=edge(seg_skull_out, 'sobel'); % this is the outer edge of skull
            seg_inner=zeros(size(bwSkullBone));
            label_brain=label_img(floor(size(bwSkullBone,1)/2),floor(size(bwSkullBone,2)/2));
            seg_inner(find(label_img==label_brain))=1;
            seg_skull_in=1-seg_inner;
            bw2=edge(seg_skull_in, 'sobel'); % this is the inner edge of skull

            outerBw = bw1;
            innerBw = bw2;

            stru_good_convexity(i_pos).outerBw = outerBw;
            stru_good_convexity(i_pos).innerBw = innerBw;

            convexity = 0;
            convexity = getConvexity(innerBw); % key point
            % convexity = getConvexityByNewMeasure(seg_skull_in);
            convexityVec = [convexityVec, convexity];
        else
            convexityVec = [convexityVec, -10000];
        end


    end
    %%%%%%%%%%%%%%%%
    [convexity_sort, convexity_ind] = sort(convexityVec,'descend');
    convexity_num = length(convexity_ind);

    threshold_convexity_num = 6; % N: change 8 to 6
    threshold_convexity_num = min(threshold_convexity_num, convexity_num);
    threshold_convexity_num = min(threshold_convexity_num,threshold_SkullArea_num);

    ind_negtive = find(convexity_sort<0);
    neg_num = length(ind_negtive);
    pos_num = length(convexity_sort) - neg_num;

    if pos_num < threshold_convexity_num
        if threshold_convexity_num ~= 0
            fprintf('\n---------------------------------------------------------------\n');
            fprintf(' The Top %d Convexity file List is : \r\n',threshold_convexity_num);
            for i_pos=1:threshold_SkullArea_num
                if i_pos <= threshold_convexity_num
                    fprintf('  sequence: %d  <--> filename:   %s <-->  Convexity value %4.3f\n', ...\
                        i_pos ,stru_good_convexity(convexity_ind(i_pos)).imgname, convexity_sort(i_pos));

                    % tmp_fn = [fullSaveDir_save_convexity_Dir,
                    % stru_good_convexity(convexity_ind(i_pos)).imgname];
                    tmp_fn = strcat(fullSaveDir_save_convexity_Dir, '/' ,stru_good_convexity(convexity_ind(i_pos)).imgname);
                    imwrite(uint8(stru_good_convexity(convexity_ind(i_pos)).img_Mattress),tmp_fn);
                end
            end
        end
    else
        if threshold_convexity_num ~= 0
            fprintf('\n---------------------------------------------------------------\n');
            fprintf(' The Top %d Convexity file List is :  \r\n',threshold_convexity_num);
            fprintf('    Because all of first %d Convexity values are same, use Intracranial Area as measure:  \r\n',threshold_convexity_num);
            for i_pos=1:skullArea_num
                if i_pos <= threshold_convexity_num
                    fprintf('  sequence: %d  <--> filename:   %s <-->  Intracranial Area %4.3f\n', i_pos ,stru_good(skullArea_ind(i_pos)).imgname,skullArea_sort(i_pos));
                    % tmp_fn = [fullSaveDir_save_skullArea_Dir, stru_good(skullArea_ind(i_pos)).imgname];
                    tmp_fn = strcat(fullSaveDir_save_convexity_Dir, '/' ,stru_good(skullArea_ind(i_pos)).imgname);
                    imwrite(uint8(stru_good(skullArea_ind(i_pos)).img_Mattress),tmp_fn);
                end
            end

        end
    end


    %% for VFM value image
    %dir(fullSaveDir_save_convexity_Dir);
    VFMVec = [];
    if isDecFormat
        % imgListForConvexity = dir([fullSaveDir_save_skullArea_Dir, '/*.dcm']);
        imgListForVFM = dir(strcat(fullSaveDir_save_convexity_Dir,'/', '*.dcm'));
    else
        % imgListForConvexity = dir([fullSaveDir_save_skullArea_Dir, '/*.jpg']);
        imgListForVFM = dir(strcat(fullSaveDir_save_convexity_Dir,'/', '*.jpg'));
    end

    % caculate the VFMVec
    i_pos_new = 0;
    for i_pos=1:threshold_convexity_num % <=> length(imgListForVFM)
        % imStru.img_Mattress = ;

        % read?in?image:?img_Mattress
        imFilePathAndName = '';
        imFilePathAndName = strcat(fullSaveDir_save_convexity_Dir, '/' ,imgListForVFM(i_pos).name);
        img_Mattress = imread(imFilePathAndName);
        if ndims(img_Mattress) ~= 2
            img_Mattress = img_Mattress(:,:,1);
        end

        rev = isCrashed(img_Mattress,250);
        if rev == 0

            [seg_kmean, VFM , rev]  = get_VFM_step2fin(uint8(img_Mattress(:,:,1)));


            if rev == 0
                VFMVec = [VFMVec, VFM];

                i_pos_new = i_pos_new + 1;
                stru_good_VFM(i_pos_new).img_Mattress =  img_Mattress;
                stru_good_VFM(i_pos_new).boneThreshold = 250;
                stru_good_VFM(i_pos_new).imgname = imgListForVFM(i_pos).name;

            end

        end


    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    [VFM_sort, VFM_ind] = sort(VFMVec,'descend');
    VFM_num = length(VFM_ind);

    threshold_VFM_num = 9;
    threshold_VFM_num = min(threshold_VFM_num, VFM_num);
    threshold_VFM_num = min(threshold_VFM_num,threshold_convexity_num);
    threshold_VFM_num = min(i_pos_new,threshold_VFM_num);

    if threshold_VFM_num ~= 0
        fprintf('\n---------------------------------------------------------------\n');
        fprintf(' The Top %d VFM file List is : \r\n',threshold_VFM_num);
        for i_pos=1:threshold_convexity_num
            if i_pos <= threshold_VFM_num
                fprintf('  sequence: %d  <--> filename:   %s <-->  VFM value %4.3f\n', ...\
                    i_pos ,stru_good_VFM(VFM_ind(i_pos)).imgname, VFM_sort(i_pos));

                tmp_fn = strcat(fullSaveDir_save_VFM_Dir, '/' ,stru_good_VFM(VFM_ind(i_pos)).imgname);
                imwrite(uint8(stru_good_VFM(VFM_ind(i_pos)).img_Mattress),tmp_fn);
            end
        end
    else
        fprintf('\n---------------------------------------------------------------\n');
        fprintf(' The VFM file List does not exist : \r\n');
    end


    %% for windows selection algorithm roughly

    %dir(fullSaveDir_save_VFM_Dir);
    WFMVec = [];
    if isDecFormat
        % imgListForConvexity = dir([fullSaveDir_save_VFM_Dir, '/*.dcm']);
        imgListForWSA = dir(strcat(fullSaveDir_save_VFM_Dir,'/', '*.dcm'));
    else
        % imgListForConvexity = dir([fullSaveDir_save_skullArea_Dir, '/*.jpg']);
        imgListForWSA = dir(strcat(fullSaveDir_save_VFM_Dir,'/', '*.jpg'));
    end

    for i_pos=1:threshold_VFM_num % threshold_VFM_num <=> length(imgListForWSA)
        % imStru.img_Mattress = ;

        % read?in?image:?img_Mattress
        imFilePathAndName = '';
        imFilePathAndName = strcat(fullSaveDir_save_VFM_Dir, '/' ,imgListForWSA(i_pos).name);
        img_Mattress = imread(imFilePathAndName);
        if ndims(img_Mattress) ~= 2
            img_Mattress = img_Mattress(:,:,1);
        end
        stru_good_WFM(i_pos).img_Mattress =  img_Mattress;
        stru_good_WFM(i_pos).boneThreshold = 250;
        stru_good_WFM(i_pos).imgname = imgListForWSA(i_pos).name;

        rev = isCrashed(img_Mattress,250);

        innerbrain_mask = '';
        stru_good_WFM(i_pos).innerbrain_mask = innerbrain_mask;
        if rev == 0
            [innerbrain_mask, rev] = getinnerbrainwhite(img_Mattress,stru_good_WFM(i_pos).boneThreshold);
            stru_good_WFM(i_pos).innerbrain_mask = innerbrain_mask;

            imStru = stru_good_WFM(i_pos);
            [   stru_good_WFM(i_pos).bwSkullBone , ...\
                stru_good_WFM(i_pos).center , ...\
                stru_good_WFM(i_pos).rev] = getSkullBoneAndCenter(imStru);

            [seg_kmean, VFM , rev]  = get_VFM_step2fin(uint8(img_Mattress(:,:,1)));

            if stru_good_WFM(i_pos).rev == 0
                WSM = 0;
                % [WSM,winStru, rev] = getWSMByCenter_innerB_kmean(stru_good_WFM(i_pos).center, innerbrain_mask, seg_kmean ); % key point
                [WSM,winStru, rev] = getWSMFromMassCent_ByCenter_innerB_kmean(stru_good_WFM(i_pos).center, innerbrain_mask, seg_kmean ); % key point

                WFMVec = [WFMVec, WSM];
                stru_good_WFM(i_pos).winStru = winStru;
            else
                WFMVec = [WFMVec, 0];
            end

        else
            WFMVec = [WFMVec, 0];
        end
    end
    %%%%%%%%%%%%%%%%
    % save to directory: fullSaveDir_save_WFM1_Dir

    [WFM_sort, WFM_ind] = sort(WFMVec,'descend');
    WFM_num = length(WFM_ind);

    threshold_WFM_num = 6;
    threshold_WFM_num = min(threshold_WFM_num, WFM_num);
    threshold_WFM_num = min(threshold_WFM_num,threshold_convexity_num);
    threshold_WFM_num = min(i_pos_new,threshold_WFM_num);

    % <++> avoid error sometimes in the following codes. 11/19/2013
    threshold_WFM_num = 0
    % </++>
    if threshold_WFM_num ~= 0
        fprintf('\n---------------------------------------------------------------\n');
        fprintf(' The Top %d WFM file List is : \r\n',threshold_WFM_num);
        for i_pos=1:threshold_VFM_num
            if i_pos <= threshold_WFM_num
                fprintf('  sequence: %d  <--> filename:   %s <-->  WFM value %4.3f\n', ...\
                    i_pos ,stru_good_WFM(WFM_ind(i_pos)).imgname, WFM_sort(i_pos));
                if WFM_sort(i_pos) ~= 0

                    tmp_fn = strcat(fullSaveDir_save_WFM1_Dir, '/' ,int2str(i_pos), '--WSM--', stru_good_WFM(WFM_ind(i_pos)).imgname);

                    tmpI = stru_good_WFM(WFM_ind(i_pos)).img_Mattress;
                    tmpW = stru_good_WFM(i_pos).winStru;
                    %                         tmpI(tmpW(2):tmpW(2)+tmpW(4),tmpW(1):tmpW(1)+1)= 249;
                    %                         tmpI(tmpW(2):tmpW(2)+tmpW(4),tmpW(1)+tmpW(3):tmpW(1)+tmpW(3)+1)= 249;
                    %                         tmpI(tmpW(1):tmpW(1)+1,tmpW(2):tmpW(2)+tmpW(4))= 249;
                    %                         tmpI(tmpW(1)+tmpW(3):tmpW(1)+tmpW(3)+1,tmpW(2):tmpW(2)+tmpW(4))= 249;

                    imwrite(uint8(tmpI),tmp_fn);

                    mask = zeros(size(tmpI));
                    mask(tmpW(2):(tmpW(2)+tmpW(4)),tmpW(1):(tmpW(1)+tmpW(3))) = 1;
                    tmpI = uint8(tmpI).*uint8(mask);

                    tmp_fn2 = strcat(fullSaveDir_save_WFM1_Dir, '/' ,int2str(i_pos), '--WSM-mask-', stru_good_WFM(WFM_ind(i_pos)).imgname);

                    imwrite(uint8(tmpI),tmp_fn2);

                    % imwrite(uint8(stru_good_WFM(WFM_ind(i_pos)).img_Mattress),tmp_fn);
                else
                    tmp_fn = strcat(fullSaveDir_save_WFM1_Dir, '/' ,'fail_WSM_', stru_good_WFM(WFM_ind(i_pos)).imgname);
                    imwrite(uint8(stru_good_WFM(WFM_ind(i_pos)).img_Mattress),tmp_fn);
                end

            end
        end
    else
        fprintf('\n---------------------------------------------------------------\n');
        fprintf(' The WFM file List is not exist : \r\n');
    end


end

%% for ideal midlinie detection

if isDecFormat
    imgList = dir(strcat(fullSaveDir_save_VFM_Dir, '/', '*.dcm'));
else
    imgList = dir(strcat(fullSaveDir_save_VFM_Dir, '/', '*.jpg'));
end

lenList = length(imgList);

if lenList == 0
    imgList = dir(strcat(fullSaveDir_save_VFM_Dir, '/', '*.png'));
    lenList = length(imgList);
end

fprintf('--------ideal mid-line detection -------- \r\n');
fprintf('The patient %s''s original list length for ideal mid-line detection is : %d . \r\n', fullImageDirRoot ,lenList);

imFilePathAndName_pre = '';
isFirstSliceOfFirstPerson = true;
person_postion = 0;
stru = '';
stru_good = '';
person_num = 1;

skullAreaVec = [];
convexityVec = [];

goodperson_postion = 0;
tmpSaveDirRoot = strcat(fullSaveDir , '/' );
for i_img = 1: lenList
    person_postion = person_postion + 1;
    imgname = imgList(i_img).name;

    %imFilePathAndName = [imageDirRoot,imgname];
    % N: it uses images before closing fractures to detect ideal Midline 
    % and assigns red line on slices after fractures are closed
    imFilePathAndName = strcat(fullSaveDir, '\SSAone_4VFM/' , imgname);
    imFilePathAndNameFractured = strcat(fullImageDirRoot, '/' , imgname);
    stru(person_postion).imFilePathAndName = imFilePathAndName;
    stru(person_postion).imFilePathAndNameFractured = imFilePathAndNameFractured;
    stru(person_postion).isDecFormat = isDecFormat;
    stru(person_postion).imageDirSaveRoot =  tmpSaveDirRoot;

    if isDecFormat
        in = strfind(imgname,'.dcm');
    else
        in = strfind(imgname,'.jpg');
    end

    stru(person_postion).imgnameWithoutExtendName = imgname(1:in-1);
end

%
%rev = get_li8_ideal_onepersonjuly10_compare_wenan(stru,true);
rev = get_li8_ideal_onepersonjuly10(stru,true);
%rev = get_li8_ideal_onepersonjuly10_NegarVersion(stru,true);
% % deal with the last person
%  print_stru(stru);
%  print_stru(stru_good);
% % not crashed
%
% rev = get_li8_ideal_onepersonjuly10(stru_good);
% fprintf('The number of Person is %d \n', person_num);

% return the selected image file list
selectedImageList = cell(length(imgList));
for i = 1:length(selectedImageList)
    selectedImageList{i} =  imgList(i).name;
end
