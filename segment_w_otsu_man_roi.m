function[bound_ret_sort,image_adam_save,button_ret]=segment_w_otsu_man_roi(im_now1,button_in,x_c,y_c)

%closing all open figures if user decides to re-draw ROI
if button_in==3
    close all;
end

%making the image rgb
gray_map=colormap(gray);
rgb_for_roipoly=make_rgb_im(im_now1,gray_map);

% %centers
% x_c=102;%y_c;
% y_c=72;%x_c;

%dimensions
dim1=size(im_now1,1);
dim2=size(im_now1,2);


%otsu calculation
thresh_val=multithresh(im_now1+150);
thresh_val=thresh_val.*0.7;
bw_image_2=im2bw(im_now1,thresh_val);


%boundary
bound1_tmp=bwboundaries(bw_image_2);

%recording size of boundary - clustering
size_bound_cluster=zeros(size(bound1_tmp,1),2);

%counter for boundary
count_bound=1;

%roipoly call
figure, hold on;
bw_mask=roipoly(rgb_for_roipoly);

%making a figure
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

%plotting of the final boundary
plot(bound_ret_sort(:,1),bound_ret_sort(:,2),'r','LineWidth',1.5);

%clear statements
%clear bw_image_2; clear bound1_tmp; clear size_bound_cluster; clear bw_mask;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%Storing the figures and %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%boundary for quality%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%control later%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% %saving current figure
% mkdir(strcat(path_save,'Images_w_Boundary\Orig\'));
% 
% saveas(gcf,strcat(path_save,'Images_w_Boundary\Orig\im',num2str(num_save),'.png'));
% 
% %closing all open figures
% close all;
% 
% %reading in cropped figure and cropping
% mkdir(strcat(path_save,'Images_w_Boundary\Final\'));
% ic=imread(strcat(path_save,'Images_w_Boundary\Orig\im',num2str(num_save),'.png'));
% ic_crop=imcrop(ic,[109,50,585,535]);
% imwrite(ic_crop,strcat(path_save,'Images_w_Boundary\Final\im',num2str(num_save),'.png'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%Saving an image with only the masked edge%%%%%%%%%%%%%%%%%

%making a double
im_now1=double(im_now1);

%a binary mask
bin_mask_adam=zeros(size(im_now1));
bin_mask_adam=double(bin_mask_adam);

%indices of boundary
idx_adam_bound=sub2ind(size(im_now1),bound_ret_sort(:,2),bound_ret_sort(:,1));

%making the mask
bin_mask_adam(idx_adam_bound)=1;

%  close all;
%  figure, imagesc(bin_mask_adam); colormap(gray); colorbar;
%  figure, imagesc(im_now1); colormap(gray); colorbar; hold on;
%  plot(bound_ret_sort(:,1),bound_ret_sort(:,2),'r','LineWidth',1.5);
%
%image to save
image_adam_save=im_now1.*bin_mask_adam;

% %making a new directory
% mkdir(strcat(path_save,'Images_Boundary_Masked\'));
% imwrite(uint16(image_adam_save),strcat(path_save,'Images_Boundary_Masked\im',num2str(num_save),'.tif'));
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%Saving the Boundary%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% %making a directory
% mkdir(strcat(path_save,'The_Boundaries\'));
% save(strcat(path_save,'The_Boundaries\Bound',num2str(num_save),'.mat'),'bound_ret_sort');



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%Final User Input%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%user input
[x,y,button_ret]=ginput(1);















