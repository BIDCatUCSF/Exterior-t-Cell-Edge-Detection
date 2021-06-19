function[ret_rgb_im]=make_rgb_im(im_start,color_for_im)


im_start=double(im_start);

dim_f=size(im_start,1);
dim_g=size(im_start,2);

min_num=min(im_start(1:(dim_f*dim_g)));
max_num=max(im_start(1:(dim_f*dim_g)));

max_num=double(max_num);
min_num=double(min_num);

im_start=im_start-min_num;
max_num=max_num-min_num;
max_num=max_num*0.3;

im_start=im_start.*(256/max_num);

ret_rgb_im=ind2rgb(uint16(im_start),color_for_im);

