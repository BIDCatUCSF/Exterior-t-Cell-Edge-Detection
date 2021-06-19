function[]=analyze_ims(file_1,path_1,numb_ims)

%removing sections of the filename
file_pre=file_1(1:((numel(file_1))-8));

%getting the index of the initial image
l_file=numel(file_1);
num_start=str2num(file_1(l_file-7:l_file-4))

%starting value
if num_start==0
    num_start=1;
end

%ending value
numb_ims
num_end=numb_ims;%-num_start+1

%finding a middle value frame from which to select the center
mid_val=uint16((num_end-num_start)*0.5);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%Reading in the images%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%and segmenting images%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%counter
count=1;

%counter from the user
count_use=0;
count_use2=0;


for i=num_start:num_end
    
    if i<=10
        im_now=imread(strcat(path_1,file_pre,'000',num2str(i-1),'.tif'));
    elseif i>10 && i<=100
        im_now=imread(strcat(path_1,file_pre,'00',num2str(i-1),'.tif'));
    else
        im_now=imread(strcat(path_1,file_pre,'0',num2str(i-1),'.tif'));
    end
    
    %making a double
    im_now=double(im_now);
    
    %ask where the center of object is 
    if count==1
        
        if mid_val<=10
            im_mid=imread(strcat(path_1,file_pre,'000',num2str(mid_val-1),'.tif'));
        elseif mid_val>10 && mid_val<100
            im_mid=imread(strcat(path_1,file_pre,'00',num2str(mid_val-1),'.tif'));
        else
            im_mid=imread(strcat(path_1,file_pre,'0',num2str(mid_val-1),'.tif'));
        end
        
%         figure, imagesc(im_mid); colormap(gray); colorbar; title('Please Left Click on Center(s) of Image');
%         [xc1,yc1]=ginput(2)
%         
%         %some formatting
%         xc1=uint16(xc1);
%         yc1=uint16(yc1);
%         
%         xc1=double(xc1);
%         yc1=double(yc1);
        
        close all;
        
    end
    
    %segment by kmeans - loop
    button=0;
    
    while button~=1
        
        i
        
        %big segmentation step
        [boundary_out,masked_im_out,button]=segment_w_kmeans_man_roi_v4(im_now,button);
        %[boundary_out,masked_im_out,button]=segment_w_kmeans_man_roi(im_now,button,xc1,yc1);
        %[boundary_out,masked_im_out,button]=segment_w_otsu_man_roi(im_now,button,xc1,yc1);
        
        %if selection is good save everything
        if button==1
            
            %iterate counter
            count_use=count_use+1;
            
            %saved the image with boundary masked
            
            %making a new directory
            if count_use==1
              mkdir(strcat(path_1,'Images_Boundary_Masked\'));
            end
            imwrite(uint16(masked_im_out),strcat(path_1,'Images_Boundary_Masked\im',num2str(i-1),'.tif'));
            
           
            %Saving the Boundary
            
            %looking to see how many boundaries there
            idx_nb=find(boundary_out(:,4)==2);
            
            
            
            %making a directory
            if numel(idx_nb)==0
                
                %save single boundary
                if count_use==1
                    mkdir(strcat(path_1,'The_Boundaries\'));
                end
                save(strcat(path_1,'The_Boundaries\Bound',num2str(i-1),'.mat'),'boundary_out');
                
            end
                
            %save multiple boundaries
            if numel(idx_nb)>0
                
                if count_use2==0
                    
                    %make directory
                    mkdir(strcat(path_1,'The_Boundaries2\'));
                    
                    %iterate counter
                    count_use2=count_use2+1;
                    
                end
                
                %separating out boundary components
                idx1k=find(boundary_out(:,4)==1);
                idx2k=find(boundary_out(:,4)==2);
                
                boundary_out_1(:,1)=boundary_out(idx1k,1);
                boundary_out_1(:,2)=boundary_out(idx1k,2);
                boundary_out_1(:,3)=boundary_out(idx1k,3);
                
                boundary_out_2(:,1)=boundary_out(idx2k,1);
                boundary_out_2(:,2)=boundary_out(idx2k,2);
                boundary_out_2(:,3)=boundary_out(idx2k,3);
                
                clear boundary_out; clear idx1k; clear idx2k;
                
                %saving boundary 1
                boundary_out=boundary_out_1;
                save(strcat(path_1,'The_Boundaries\Bound',num2str(i-1),'.mat'),'boundary_out');
                
                %saving boundary 2
                clear boundary_out;
                boundary_out=boundary_out_2;
                save(strcat(path_1,'The_Boundaries2\Bound',num2str(i-1),'.mat'),'boundary_out');
                
                %clear statements;
                clear boundary_out; clear boundary_out_1; clear boundary_out_2;
                
                
            end
            
            %Saving the figure with the boundary
            %saving current figure
            
            if count_use==1
                mkdir(strcat(path_1,'Images_w_Boundary\Orig\'));
            end
            
            saveas(gcf,strcat(path_1,'Images_w_Boundary\Orig\im',num2str(i-1),'.png'));
            
            %closing all open figures
            close all;

            %reading in cropped figure and cropping
            
            if count_use==1
                mkdir(strcat(path_1,'Images_w_Boundary\Final\'));
            end
            
            ic=imread(strcat(path_1,'Images_w_Boundary\Orig\im',num2str(i-1),'.png'));
            ic_crop=imcrop(ic,[109,50,585,535]);
            imwrite(ic_crop,strcat(path_1,'Images_w_Boundary\Final\im',num2str(i-1),'.png'));
            
            
        end

    end
    
    %pre-allocating for speed
    if count==1
        dim1=size(im_now,1);
        dim2=size(im_now,2);
        big_im1=zeros(dim1,dim2,numb_ims);
        big_im1=double(big_im1);
    end
    
    
    
    %storing
    big_im1(:,:,count)=im_now;
    
    %iterat counter
    count=count+1;
    

    %clear statements
    clear im_now;
    
    
end




























