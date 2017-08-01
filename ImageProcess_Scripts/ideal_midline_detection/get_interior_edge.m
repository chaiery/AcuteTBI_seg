%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Wenan Chen
%% Nov, 2007
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% This function detect the interior edge of the skull. 

function edge_map=get_interior_edge(bwimg)
%% input: binary image with foreground 1 and background 0
%% output: set of points to form a curve

curve=[];

tB=bwimg;
tB=1-tB;
%% fill all other parts of the backgound except the interior brain tissue

L = bwlabel(tB, 4); 
%% assume the midpoint of the bottom line in the brain tissue
mid_bottom=[size(tB,1), floor(size(tB,2)/2)];
label=L(mid_bottom(1),mid_bottom(2));

%% white foreground 
BW=ones(size(bwimg));

BW(find(L==label))=0; %% fill the brain tissue part

% BW_=bwmorph(BW,'open');

%% get the edge of the brain to avoid cossing point in the following edge
BW2=1-BW;
%BW2_=imfill(BW2, 'holes');
BW3=bwmorph(BW2, 'open'); %% get rid of the spurs and make it more smooth.
BW4=bwmorph(BW3, 'remove');


%% get the largest line
[L2, num] = bwlabel(BW4);
lg_L=1;
lg_num=0;
for i=1:num
    if(length(find(L2==i))>lg_num)
        lg_L=i;
        lg_num=length(find(L2==i));
    end
end

edge_map=zeros(size(BW4));
edge_map(find(L2==lg_L))=1;

%%clear four edges of the window
edge_map([1,size(edge_map,1)],:)=0;
edge_map(:, [1,size(edge_map,2)])=0;

    






