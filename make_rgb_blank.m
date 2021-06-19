function[ret_rgb_im]=make_rgb_blank(im_start,max_num)

%colormaps
jet_map=colormap(jet);
gray_map=[0,0,0;1,1,1];

%image properties
im_start=double(im_start);
dim_f=size(im_start,1);
dim_g=size(im_start,2);

%BW image
bw_austin=zeros(size(im_start));
bw_austin=double(bw_austin);
idx_austin=find(im_start>0);
bw_austin(idx_austin)=1;

%rgb rendering
bw_austin_rgb=ind2rgb(uint16(bw_austin),gray_map);
% figure, imagesc(bw_austin); title('Test'); colormap(gray); colorbar;
% figure, imshow(bw_austin_rgb);
% figure, imagesc(im_start); colormap(jet); colorbar; title('Test');


min_num=0;

max_num=double(max_num);
min_num=double(min_num);

im_start=im_start-min_num;
max_num=max_num-min_num;
max_num=max_num*1;

im_start=im_start.*(64/max_num);

the_rgb_im=ind2rgb(uint16(im_start),jet_map);

ret_rgb_im(:,:,1)=the_rgb_im(:,:,1).*bw_austin_rgb(:,:,1);
ret_rgb_im(:,:,2)=the_rgb_im(:,:,2).*bw_austin_rgb(:,:,2);
ret_rgb_im(:,:,3)=the_rgb_im(:,:,3).*bw_austin_rgb(:,:,3);


