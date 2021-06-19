function[bound_back,button_ret1,x_c,y_c]=segment_ind_objects(im_now1,button_in)



%closing all open figures if user decides to re-draw ROI
if button_in==3
    close all;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%roipoly call%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%This was moved up higher in code for v3

%making the image rgb
gray_map=colormap(gray);
rgb_for_roipoly=make_rgb_im(im_now1,gray_map);

figure, hold on; title('Indicate Area to be Initially Masked');
bw_mask=roipoly(rgb_for_roipoly);

%doing a masking before the clustering
im_now1=double(im_now1);
bw_mask=double(bw_mask);
im_now1=im_now1.*bw_mask;



% %centers
% x_c=102;%y_c;
% y_c=72;%x_c;

%centers
[the_centers]=calc_centroid_of_slice(im_now1)
x_c=the_centers(1);
y_c=the_centers(2);

%dimensions
dim1=size(im_now1,1);
dim2=size(im_now1,2);

%kmeans clustering
IDX_k=kmeans([im_now1(1:(dim1*dim2))]',2,'emptyaction','singleton','replicates',50,'start','uniform','distance','cityblock');

bw_image=zeros(size(im_now1));
bw_image(1:(dim1*dim2))=IDX_k;
idx_1=find(bw_image==1);
idx_2=find(bw_image==2);
%idx_3=find(bw_image==3);

%finding highest cluster
% cluster_arr=[[1;2;3],[mean(im_now1(idx_1));mean(im_now1(idx_2));mean(im_now1(idx_3))]];
% cluster_arr_sort=sortrows(cluster_arr,2)
% 
% if cluster_arr_sort(2,1)==1
%     high_cluster1=idx_1;
% elseif cluster_arr_sort(2,1)==2
%     high_cluster1=idx_2;
% else
%     high_cluster1=idx_3;
% end
% 
% 
% if cluster_arr_sort(3,1)==1
%     high_cluster2=idx_1;
% elseif cluster_arr_sort(3,1)==2
%     high_cluster2=idx_2;
% else
%     high_cluster2=idx_3;
% end
% 
% high_cluster=[high_cluster1;high_cluster2];

if mean(im_now1(idx_1))>mean(im_now1(idx_2))
    high_cluster=idx_1;
else
    high_cluster=idx_2;
end






%boundary
bw_image_2=zeros(size(im_now1));
bw_image_2(high_cluster)=1;
bound1_tmp=bwboundaries(bw_image_2);

%recording size of boundary - clustering
size_bound_cluster=zeros(size(bound1_tmp,1),2);

%counter for boundary
count_bound=1;

%roipoly call
figure, hold on; title('Indicate Area of Cell');
bw_mask=roipoly(rgb_for_roipoly);

%making a figure
figure, imagesc(im_now1); colormap(gray); colorbar;
figure, imagesc(im_now1); colormap(gray); colorbar;
hold on; title('Left Click - ok , Right Click - ReDo');

for u=1:size(bound1_tmp,1)
    
    %get boundary
    bound1=bound1_tmp{u};
    
    %convert to indices
    [idx_b]=sub2ind(size(im_now1),bound1(:,1),bound1(:,2));
    
    %array to check
    array_where=bw_mask(idx_b);
    idx_where=find(array_where<1);
    
    if numel(idx_where)==0 || (numel(idx_where)/numel(idx_b))<0.2
        
        %recording the size of the clustering boundary
        size_bound_cluster(count_bound,1)=u;
        size_bound_cluster(count_bound,2)=numel(bound1(:,2));
        
        %plot boundary
        plot(bound1(:,2),bound1(:,1),'g','LineWidth',1.5,'MarkerSize',12);
        %plot(y_c, x_c,'y+','LineWidth',1.5,'MarkerSize',12);
        
        %storing the entire bound
        if count_bound==1
            bound_keep(:,1)=bound1(:,1);
            bound_keep(:,2)=bound1(:,2);
        else
            bound_keep_tmp=bound_keep;
            clear bound_keep;
            bound_keep=[bound_keep_tmp;[bound1(:,1),bound1(:,2)]];
            clear bound_keep_tmp;
        end
        
        %iterate counter
        count_bound=count_bound+1;
        
    end
    
    %clear statements
    clear bound1; clear array_where; clear idx_where;
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%Final calculation of boundary%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%using angle to return%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%debugging
%plot(bound_keep(:,2),bound_keep(:,1),'g+','LineWidth',1.5,'MarkerSize',12);

%calculating angular position
[ang_arr]=calc_angle(bound_keep,x_c,y_c,im_now1);

%distances from the center
ang_arr(:,4)=(((ang_arr(:,1)-x_c).^2)+((ang_arr(:,2)-y_c).^2)).^0.5;

%sorting matrix by angle
sort_ang_arr=sortrows(ang_arr,3);

%final counter to make boundary to return
count_ret=1;

for k=1:365
    
    if k==1
        idx_s=0;
        idx_e=1;
    else
        idx_s=idx_e;
        idx_e=idx_s+1;
    end
    
    %convert to radians
    idx_s=double(idx_s); idx_st=idx_s*(pi/180);
    idx_e=double(idx_e); idx_et=idx_e*(pi/180);
    
    
    %getting a "section" of boundary by angle
    idx_low_tmp=find(sort_ang_arr(:,3)>=idx_st);
    idx_high_tmp=find(sort_ang_arr(:,3)<=idx_et);
    
    %clear statements
    clear idx_st; clear idx_et;
    
    if numel(idx_low_tmp)>0 || numel(idx_high_tmp)>0
        
        if numel(idx_low_tmp)>0 && numel(idx_high_tmp)>0
            idx_low=idx_low_tmp(1);
            idx_high=idx_high_tmp(numel(idx_high_tmp));
        elseif numel(idx_low_tmp)>0 && numel(idx_high_tmp)==0
            idx_low=idx_low_tmp(1);
            idx_high=numel(sort_ang_arr(:,1));
        else % numel(idx_low_tmp)==0 && numel(idx_high_tmp)>0
            idx_low=1;
            idx_high=idx_high_tmp(numel(idx_high_tmp));
        end
        
        %outlier case when code looks at first elemt in sort_ang_arr
        if idx_high < idx_low
            idx_high1=idx_high;clear idx_highl
            idx_low1=idx_low; clear idx_low;
            idx_low=idx_high1;
            idx_high=idx_low1;
        end
            
       
        
        %sectioning out pieces of matrix
        the_sect(:,1)=sort_ang_arr(idx_low:idx_high,1); %x
        the_sect(:,2)=sort_ang_arr(idx_low:idx_high,2); %y
        the_sect(:,3)=sort_ang_arr(idx_low:idx_high,4); %dist
        the_sect(:,4)=sort_ang_arr(idx_low:idx_high,3); %angle
        
        %sorting
        the_sect_sort=sortrows(the_sect,3);
        
        %final boundary
        %         idx_low_tmp
        %         idx_high_tmp
                 idx_low
                 idx_high
                 the_sect_sort
        
        final_bound(count_ret,1)=the_sect_sort(numel(the_sect_sort(:,1)),1);%x
        final_bound(count_ret,2)=the_sect_sort(numel(the_sect_sort(:,1)),2);%y
        final_bound(count_ret,3)=the_sect_sort(numel(the_sect_sort(:,1)),4);%angle
        final_bound(count_ret,4)=the_sect_sort(numel(the_sect_sort(:,1)),3); %distance to centroid
        
        %iterate counter
        count_ret=count_ret+1;
        
        %clear statements
        clear the_sect; clear the_sect_sort;
        
    end
    
    %clear statements
    clear idx_low_tmp; clear idx_high_tmp;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%Final filtering step%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%another colormap
% the_map=colormap(jet);

%sorting the boundary again
final_bound_sort=sortrows(final_bound,3);

%original boundary
%sort_ang_arr

%counter
count_w=1;


for w=1:93
    
    %indices to look through to find distance
    if w==1
        idx_1=0;
        idx_2=5;
    else
        idx_1=idx_2+0;
        idx_2=idx_1+4;
    end
    
    %convert to radians
    idx_1a=double(idx_1)
    idx_2a=double(idx_2)
    idx_1a=idx_1.*(pi/180);
    idx_2a=idx_2.*(pi/180);
    
    %finding distance - low boundary
    idx_bot_tmp=find(final_bound_sort(:,3)>=idx_1a);
    
    if numel(idx_bot_tmp)>0
        idx_bot=idx_bot_tmp(1)
    else
        idx_bot=1;
    end
    
    %finding distance - high boundary
    idx_high_tmp=find(final_bound_sort(:,3)<=idx_2a);
    
    if numel(idx_high_tmp)>0
        idx_high=idx_high_tmp(numel(idx_high_tmp))
    else
        idx_high=numel(final_bound_sort(:,3));
    end
    
    %finding distance
    if idx_bot>idx_high
        idx_high1=idx_high;
        idx_bot1=idx_bot;
        clear idx_bot; clear idx_high;
        idx_bot=idx_high1;
        idx_high=idx_bot1;
        clear idx_bot1; clear idx_high1;
    end
    
    
    most_com_dist=max(uint16(final_bound_sort(idx_bot:idx_high,4)));
    most_com_dist=double(most_com_dist)
    
    
    
    %going through original list to get coordinates at this angle
    idx_bot2_tmp=find(sort_ang_arr(:,3)>=idx_1a);
    
    if numel(idx_bot2_tmp)>0
        idx_bot2=idx_bot2_tmp(1);
    else
        idx_bot2=1;
    end
    
    idx_high2_tmp=find(sort_ang_arr(:,3)<=idx_2a);
    
    if numel(idx_high2_tmp)>0
        idx_high2=idx_high2_tmp(numel(idx_high2_tmp));
    else
        idx_high2=numel(sort_ang_arr(:,3));
    end
    
    sect_orig_coord=sort_ang_arr(idx_bot2:idx_high2,:);
    
    
    
    for q=1:numel(sect_orig_coord(:,1))
        
        if (sect_orig_coord(q,4)>=(most_com_dist-(0.06*most_com_dist))) && (sect_orig_coord(q,4)<=(1.06*most_com_dist))
            bound_ret(count_w,1)=sect_orig_coord(q,1);
            bound_ret(count_w,2)=sect_orig_coord(q,2);
            bound_ret(count_w,3)=sect_orig_coord(q,3);
            count_w=count_w+1;
            % plot(sect_orig_coord(q,1),sect_orig_coord(q,2),'r+');
        end
        
    end
    
    %clear statements
    clear idx_bot_tmp; clear idx_bot; clear idx_high_tmp; clear idx_high;
    clear most_com_dist;clear idx_bot2_tmp; clear idx_bot2; clear idx_high2_tmp; clear idx_high2;
    clear sect_orig_coord;
    
    
end

%some sorting
bound_ret_sort=sortrows(bound_ret,3);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%One More quality control step%%%%%%%%%%%%%%%%%%%%%%%

%centers
%x_c
%y_c

%renaming the boundary being returned
bound_ret_sort2=bound_ret_sort;

%calculate distance to center
bound_ret_sort2(:,4)=(((bound_ret_sort2(:,1)-x_c).^2)+((bound_ret_sort2(:,2)-y_c).^2)).^0.5;

%statistics of distance
max_dist_ken=max(bound_ret_sort2(:,4));

%sorting this matrix
idx_lose_last=find(bound_ret_sort2(:,4)<=(0.33*max_dist_ken));

%removing these near elements
if numel(idx_lose_last)>0
    bound_ret_sort2(idx_lose_last,:)=[];
end

%plotting of the final boundary
%plot(bound_ret_sort2(:,1),bound_ret_sort2(:,2),'y+','LineWidth',1.5);

%plotting the center
%plot(x_c,y_c,'y+','LineWidth',1.5,'MarkerSize',12);


%clear statements
%clear bw_image_2; clear bound1_tmp; clear size_bound_cluster; clear bw_mask;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%Final Quality Control Step%%%%%%%%%%%%%%%%%%%%%%%%%%%

bw_jor=poly2mask(bound_ret_sort2(:,1),bound_ret_sort2(:,2),size(im_now1,1),size(im_now1,2));

%two rounds of dilation
nhood=[0 1 0; 1 1 1; 0 1 0];
J = imdilate(bw_jor,nhood);
J2 = imdilate(J,nhood);

%final mask
final_mask_tmp11=J+J2;
idx_use11=find(final_mask_tmp11>0);

final_mask11=zeros(size(im_now1,1),size(im_now1,2));
final_mask11(idx_use11)=1;
final_mask11=double(final_mask11);

final_masked_im11=im_now1.*final_mask11;

dim111=size(im_now1,1);
dim211=size(im_now1,2);
IDX_k11=kmeans([final_masked_im11(1:(dim111*dim211))]',2,'emptyaction','singleton','replicates',50,'start','uniform','distance','cityblock');

bw_image11=zeros(size(im_now1));
bw_image11(1:(dim111*dim211))=IDX_k11;
idx_1ab=find(bw_image11==1);
idx_2ab=find(bw_image11==2);

if mean(im_now1(idx_1ab))>mean(im_now1(idx_2ab))
    high_cluster1=idx_1ab;
else
    high_cluster1=idx_2ab;
end

bw_im2a=zeros(size(im_now1));
bw_im2a(high_cluster1)=1;
idx_add_more=find(bw_jor>0);
bw_im2a(idx_add_more)=1;

bound2a_tmp=bwboundaries(bw_im2a);

for i=1:size(bound2a_tmp,1)
    
   i
   bound2a=bound2a_tmp{i};
  
   if i==1
       bound_2_ret_final(:,1)=bound2a(:,1);
       bound_2_ret_final(:,2)=bound2a(:,2);
   else
       bound_2_ret_final_tmp=bound_2_ret_final;
       clear bound_2_ret_final;
       bound_2_ret_final=[bound_2_ret_final_tmp;[bound2a(:,1),bound2a(:,2)]];
       clear bound_2_ret_final_tmp;
   end
   
   clear bound2a;
    
end



%re-organizing so that the plots look better
bound_br=bound_2_ret_final;
clear bound_2_ret_final
bound_br_pre_sort=calc_angle(bound_br,x_c,y_c,im_now1);
bound_br_sort=sortrows(bound_br_pre_sort,3);
bound_2_ret_final(:,1)=bound_br_sort(:,2);
bound_2_ret_final(:,2)=bound_br_sort(:,1);

%plotting
plot(bound_2_ret_final(:,2),bound_2_ret_final(:,1),'r+','LineWidth',1.5);
plot(x_c(1),y_c(1),'y+','MarkerSize',12,'LineWidth',1.5);

%!!!!!!!!!
%!!!!!!!!!!!
%%%%%redefining output

clear bound_ret_sort2;
bound_back=bound_2_ret_final;

%user input
[x,y,button_ret1]=ginput(1);
