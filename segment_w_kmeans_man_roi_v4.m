function[bound_ret_sort2,image_adam_save,button_ret]=segment_w_kmeans_man_roi_v4(im_now1,button_in)

%asking if there is one or two cells
prompt='Is there 1 or 2 cells in the image? (1/2)';
str=input(prompt,'s');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%asking the user to define background%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%making the image rgb
gray_map=colormap(gray);
rgb_for_bk=make_rgb_im(im_now1,gray_map);

figure, hold on; title('Indicate Area for background removal');
bw_mask_bk=roipoly(rgb_for_bk);

idx_bk=find(bw_mask_bk>0);
avg_bk=mean(im_now1(idx_bk));

im_now1=im_now1-avg_bk;

idx_below=find(im_now1<0);
im_now1(idx_below)=0;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%getting boundary for individual objects%%%%%%%%%%%%%%%%%%%%%%%%%%%

if str == '2'
    
    button_ret1=button_in;
    button_ret2=button_in;
    
    while button_ret1 ~= 1
        [bound_obj_1_tmp,button_ret1]=segment_ind_objects(im_now1,button_ret1);
    end
    
    while button_ret2~=1
        [bound_obj_2_tmp,button_ret2]=segment_ind_objects(im_now1,button_ret2);
    end
    
    if button_ret1 == 1 && button_ret2 ==1
        button_ret=1;
    end
    
    %getting the angle
    bound_obj_1a=calc_angle(bound_obj_1_tmp,x_c(1),y_c(1),im_now1);
    bound_obj_2a=calc_angle(bound_obj_2_tmp,x_c(2),y_c(2),im_now1);
    
    %sorting by angle
    bound_obj_1=sortrows(bound_obj_1a,3);
    bound_obj_2=sortrows(bound_obj_2a,3);
    
    %adding a column
    bound_obj_1(:,4)=[linspace(1,1,numel(bound_obj_1(:,3)))]';
    bound_obj_2(:,4)=[linspace(2,2,numel(bound_obj_2(:,3)))]';
    
    bound_ret_sort2=[bound_obj_1;bound_obj_2];
    
else
    
    %assuming the bottom cell is the most persistent
    button_ret1=button_in;
    
    while button_ret1 ~= 1
        [bound_obj_1_tmp,button_ret1,x_c,y_c]=segment_ind_objects(im_now1,button_ret1);
    end
    
    %getting the angle
    bound_obj_1a=calc_angle(bound_obj_1_tmp,x_c(1),y_c(1),im_now1);
    
    %sorting by angle
    bound_obj_1=sortrows(bound_obj_1a,3);
    
    %adding a column
    bound_obj_1(:,4)=[linspace(1,1,numel(bound_obj_1(:,3)))]';
    
    if button_ret1 == 1
        button_ret=1;
    end
    
    bound_ret_sort2=[bound_obj_1];
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%Saving an image with only the masked edge%%%%%%%%%%%%%%%%%

%making a double
im_now1=double(im_now1);

%a binary mask
bin_mask_adam=zeros(size(im_now1));
bin_mask_adam=double(bin_mask_adam);

%indices of boundary
idx_adam_bound=sub2ind(size(im_now1),bound_ret_sort2(:,2),bound_ret_sort2(:,1));

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

















