function[]=create_max_proj(im_stack,max_rgb,g_button)

size(im_stack)

%dimensions of image
dimA=size(im_stack,1);
dimB=size(im_stack,2);

%maximum intensity image
max_im=zeros(dimA,dimB);

for i=1:dimA
    
    for j=1:dimB
        
       
        max_im(i,j)=max(im_stack(i,j,:));
        
    end
    
    
end

%colormaps
green_map=[   0.0417         0         0
    0.0833         0         0
    0.1250         0         0
    0.1667         0         0
    0.2083         0         0
    0.2500         0         0
    0.2917         0         0
    0.3333         0         0
    0.3750         0         0
    0.4167         0         0
    0.4583         0         0
    0.5000         0         0
    0.5417         0         0
    0.5833         0         0
    0.6250         0         0
    0.6667         0         0
    0.7083         0         0
    0.7500         0         0
    0.7917         0         0
    0.8333         0         0
    0.8750         0         0
    0.9167         0         0
    0.9583         0         0
    1.0000         0         0
    1.0000    0.0417         0
    1.0000    0.0833         0
    1.0000    0.1250         0
    1.0000    0.1667         0
    1.0000    0.2083         0
    1.0000    0.2500         0
    1.0000    0.2917         0
    1.0000    0.3333         0
    1.0000    0.3750         0
    1.0000    0.4167         0
    1.0000    0.4583         0
    1.0000    0.5000         0
    1.0000    0.5417         0
    1.0000    0.5833         0
    1.0000    0.6250         0
    1.0000    0.6667         0
    1.0000    0.7083         0
    1.0000    0.7500         0
    1.0000    0.7917         0
    1.0000    0.8333         0
    1.0000    0.8750         0
    1.0000    0.9167         0
    1.0000    0.9583         0
    1.0000    1.0000         0
    1.0000    1.0000    0.0625
    1.0000    1.0000    0.1250
    1.0000    1.0000    0.1875
    1.0000    1.0000    0.2500
    1.0000    1.0000    0.3125
    1.0000    1.0000    0.3750
    1.0000    1.0000    0.4375
    1.0000    1.0000    0.5000
    1.0000    1.0000    0.5625
    1.0000    1.0000    0.6250
    1.0000    1.0000    0.6875
    1.0000    1.0000    0.7500
    1.0000    1.0000    0.8125
    1.0000    1.0000    0.8750
    1.0000    1.0000    0.9375
    1.0000    1.0000    1.0000];

red_map=colormap(hot);

%[ret_rgb_im]=make_rgb_blank(max_im,max_rgb);

if g_button==1
    figure, imagesc(max_im);colormap(green_map); colorbar
    figure, surf(flipud(max_im)); colormap(green_map); axis tight; shading interp; colorbar; 
else
    figure, imagesc(max_im);colormap(red_map); colorbar
    figure, surf(flipud(max_im)); colormap(red_map); axis tight; shading interp; colorbar; 
end
    
    