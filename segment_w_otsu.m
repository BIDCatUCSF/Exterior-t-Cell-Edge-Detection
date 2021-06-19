function[]=segment_w_otsu(im_now1)


%trying just an Otsu thresholding calculation
thresh=graythresh(uint16(im_now1));
bw_im=im2bw(im_now1,thresh*1.6);
bound_tmp=bwboundaries(bw_im);

%making a figure
figure, imagesc(im_now1); colormap(gray); colorbar; hold on;

%getting the largest object in the frame
size_bound=zeros(size(bound_tmp,1),2);


for j=1:size(bound_tmp,1)
    
    %a boundary
    bound=bound_tmp{j};
    
    %storing
    size_bound(j,1)=j;
    size_bound(j,2)=size(bound,1);
%     
%     plot(bound(:,2),bound(:,1),'r','LineWidth',1.5);
    
    %clear statements
    clear bound;
    
end

%getting the largest boundary
max_bound=max(size_bound(:,2));
idx_max_bound=find(size_bound(:,2)==max_bound);
bound_plot=bound_tmp{size_bound(idx_max_bound(1))};
plot(bound_plot(:,2),bound_plot(:,1),'g','LineWidth',1.5);




















