function[the_centers]=calc_centroid_of_slice(im1)

%This is a function written to calculate the centroid of an image slice

%making the input image binary
idx_adam=find(im1>0);

if numel(idx_adam)>0
    
    %binary image
    bin_adam=zeros(size(im1));
    bin_adam=double(bin_adam);
    bin_adam(idx_adam)=1;

    %calculating the centroid
    s=regionprops(bin_adam,'centroid');
    the_centers=s.Centroid

%     the_centers=[uint16(size(im1,2)*0.5),uint16(size(im1,1)*0.5)];
    
    %this is condition if the image is blank
else
    
    the_centers=[0,0];
    
end

























