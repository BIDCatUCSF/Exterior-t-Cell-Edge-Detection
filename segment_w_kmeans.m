function[]=segment_w_kmeans(im_now1,num_save)

%border size - boundary has to be at least this far away from the edge to
%be considered
bound_ex=18;

%dimensions
dim1=size(im_now1,1);
dim2=size(im_now1,2);

%making a figure
figure, imagesc(im_now1); colormap(gray); colorbar; 
hold on;
plot(dim2./2, dim1./2,'y+','LineWidth',1.5,'MarkerSize',12);

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

for u=1:size(bound1_tmp,1)
    
    %get boundary
    bound1=bound1_tmp{u};
    
    %extrema of boundary
    yb_min=min(bound1(:,1));
    yb_max=max(bound1(:,1));
    xb_min=min(bound1(:,2));
    xb_max=max(bound1(:,2));
    
    if (yb_min>=bound_ex) && (xb_min>=bound_ex) && (yb_max<=(dim1-bound_ex)) && (xb_max<=(dim2-bound_ex))
  
        %recording the size of the clustering boundary
        size_bound_cluster(count_bound,1)=u;
        size_bound_cluster(count_bound,2)=numel(bound1(:,2));
        
        %plot boundary
        plot(bound1(:,2),bound1(:,1),'g','LineWidth',1.5);
        
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
    clear bound1;
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%Final calculation of boundary%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%using angle to return%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%debugging 
%plot(bound_keep(:,2),bound_keep(:,1),'g+','LineWidth',1.5,'MarkerSize',12);

%calculating angular position
[ang_arr]=calc_angle(bound_keep,dim2./2,dim1./2,im_now1);

%adding a column for distances from the center
x_c=dim2./2;
y_c=dim1./2;

%distances from the center
ang_arr(:,4)=(((ang_arr(:,1)-x_c).^2)+((ang_arr(:,2)-y_c).^2)).^0.5;

%sorting matrix by angle
sort_ang_arr=sortrows(ang_arr,3);

%final counter to make boundary to return
count_ret=1;

for k=1:120
    
    if k==1
        idx_s=0;
        idx_e=1;
    else
        idx_s=idx_e+1;
        idx_e=idx_s+3;
    end
    
    %convert to radians
    idx_s=double(idx_s); idx_st=idx_s*(pi/180);
    idx_e=double(idx_e); idx_et=idx_e*(pi/180);
    
    %getting a "section" of boundary by angle
    idx_low_tmp=find(sort_ang_arr(:,3)>idx_st);
    idx_high_tmp=find(sort_ang_arr(:,3)<idx_et);
    
    %clear statements
    clear idx_st; clear idx_et;
    
    if numel(idx_low_tmp)>0 || numel(idx_high_tmp)>0
    
        if numel(idx_low_tmp)>0 && numel(idx_high_tmp)>0
            idx_low=idx_low_tmp(1)-1;
            idx_high=idx_high_tmp(numel(idx_high_tmp));
        elseif numel(idx_low_tmp)>0 && numel(idx_high_tmp)==0
            idx_low=idx_low_tmp(1)-1;
            idx_high=numel(sort_ang_arr(:,1));
        else % numel(idx_low_tmp)==0 && numel(idx_high_tmp)>0
            idx_low=1;
            idx_high=idx_high_tmp(numel(idx_high_tmp));
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
%         idx_low
%         idx_high
%         the_sect_sort
  
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

%counter to hold this selection of the boundary
count_sel=1;

%pre-allocating for spede
bound_sel_1=zeros(numel(final_bound_sort(:,1))-1,5);
bound_sel_1=double(bound_sel_1);

%selection part 1
for r=1:(numel(final_bound_sort(:,1))-1)

    %distances to neighbors
    bound_sel_1(count_sel,1)=final_bound_sort(r,1);
    bound_sel_1(count_sel,2)=final_bound_sort(r,2);
    bound_sel_1(count_sel,3)=(((final_bound_sort(r,1)-final_bound_sort(r+1,1))^2)+((final_bound_sort(r,2)-final_bound_sort(r+1,2))^2))^0.5;
    bound_sel_1(count_sel,4)=final_bound_sort(r,3);
    bound_sel_1(count_sel,5)=final_bound_sort(r,4);
    
    %iterate counter
    count_sel=count_sel+1;


    %clear statements
    %clear color_idx;
    
end

plot(bound_sel_1(:,1),bound_sel_1(:,2),'m+','MarkerSize',12,'LineWidth',1.5);


%selection part 2

%locate the outliers
idx_s2=find(bound_sel_1(:,3)>=15);

for t=1:numel(idx_s2)
    
    %the outlier
    plot(bound_sel_1(idx_s2(t),1),bound_sel_1(idx_s2(t),2),'c+','LineWidth',1.5);
    
    
    if t<numel(idx_s2) && t>1
        if (bound_sel_1(idx_s2(t),5) >= ((bound_sel_1(idx_s2(t+1),5))*0.8)) && (bound_sel_1(idx_s2(t),5) >= ((bound_sel_1(idx_s2(t-1),5))*0.8))
             plot(bound_sel_1(idx_s2(t),1),bound_sel_1(idx_s2(t),2),'y+','LineWidth',1.5);
        end
    else
        if t>2
            if ((bound_sel_1(idx_s2(t),5) >= ((bound_sel_1(idx_s2(t-1),5))*0.8))) && ((bound_sel_1(idx_s2(t),5) >= ((bound_sel_1(idx_s2(t-2),5))*0.8)))
                    plot(bound_sel_1(idx_s2(t),1),bound_sel_1(idx_s2(t),2),'y+','LineWidth',1.5);
            end
        end
        
         if t==1
            if ((bound_sel_1(idx_s2(t),5) >= ((bound_sel_1(idx_s2(t+1),5))*0.8))) && ((bound_sel_1(idx_s2(t),5) >= ((bound_sel_1(idx_s2(t+2),5))*0.8)))
                    plot(bound_sel_1(idx_s2(t),1),bound_sel_1(idx_s2(t),2),'y+','LineWidth',1.5);
            end
         end
        
         if t==2
             if ((bound_sel_1(idx_s2(t),5) >= ((bound_sel_1(idx_s2(1),5))*0.8))) && ((bound_sel_1(idx_s2(t),5) >= ((bound_sel_1(idx_s2(3),5))*0.8)))
                 plot(bound_sel_1(idx_s2(t),1),bound_sel_1(idx_s2(t),2),'y+','LineWidth',1.5);
             end
         end
             
        
    end
    
end









% %bs array
% idx_s2=[1,2.3,4];
% 
% while numel(idx_s2)~=0
%     
%    %clearing
%    clear idx_s2;
%    
%    %finding outliers
%    idx_s2=find(bound_sel_1(:,3)>=12);
%    
%    
%    %finding out centroid distances of neighbors
%    if numel(idx_s2)>1
%        
%        if idx_s2(1)>3
%            dist_set=bound_sel_1(idx_s2(1)-3:idx_s2(1)-1,5);
%            min_dist_check=min(dist_set);
%        else
%            dist_set=bound_sel_1(idx_s2(2)+1:idx_s2(2)+3,5);
%            min_dist_check=min(dist_set);
%        end
%        
%        %angular position of outliers
%        ang_out=bound_sel_1(idx_s2(1):idx_s2(2),4);
%        min_ang_out=min(ang_out);
%        max_ang_out=max(ang_out);
% 
%        %look around original boundary for coordinates to insert into this
%        %location
%        idx_a1_tmp=find(sort_ang_arr(:,3)>=min_ang_out);
%        idx_a1=idx_a1_tmp(1);
%        
%        idx_a2_tmp=find(sort_ang_arr(:,3)<=max_ang_out);
%        idx_a2=idx_a2_tmp(numel(idx_a2_tmp));
%        
%        %getting all original coordinates from initial boundary calculation
%        sort_ang_arr_2_tmp=sort_ang_arr(idx_a1:idx_a2,:);
%        sort_ang_arr_3_tmp=sortrows(sort_ang_arr_2_tmp,4)
%        
%        %finding all internal coordinates
%        idx_internal_tmp=find(sort_ang_arr_3_tmp(:,4)<=min_dist_check*(0.95))
% 
%        
%        if numel(idx_internal_tmp)>0
%            
%             idx_internal=idx_internal_tmp(numel(idx_internal_tmp))
%             
%             sort_ang_arr_3_tmp(idx_internal,4)
%             
%             %removing outlier elements
%             bound_sel_1((idx_s2(1)):idx_s2(2),:)=[];
%             
%             %adding new elements to bottom
%             bound_sel_1(numel(bound_sel_1,1)+1,1)=sort_ang_arr_3_tmp(idx_internal,1);
%             bound_sel_1(numel(bound_sel_1,1)+1,2)=sort_ang_arr_3_tmp(idx_internal,2);
%             bound_sel_1(numel(bound_sel_1,1)+1,3)=0;
%             bound_sel_1(numel(bound_sel_1,1)+1,4)=sort_ang_arr_3_tmp(idx_internal,3);
%             
% %             bound_sel_1((idx_s2(1)):idx_s2(2),1)=[linspace(sort_ang_arr_3_tmp(idx_internal,1),sort_ang_arr_3_tmp(idx_internal,1),numel([idx_s2(1):idx_s2(2)]))]';
% %             bound_sel_1((idx_s2(1)):idx_s2(2),2)=[linspace(sort_ang_arr_3_tmp(idx_internal,2),sort_ang_arr_3_tmp(idx_internal,2),numel([idx_s2(1):idx_s2(2)]))]';
% %             bound_sel_1((idx_s2(1)):idx_s2(2),3)=[linspace(0,0,numel([idx_s2(1):idx_s2(2)]))]';
% %             bound_sel_1((idx_s2(1)):idx_s2(2),4)=[linspace(sort_ang_arr_3_tmp(idx_internal,3),sort_ang_arr_3_tmp(idx_internal,3),numel([idx_s2(1):idx_s2(2)]))]';
% 
%             %clear statements
%             clear idx_internal;
%             
%        else
%            bound_sel_1((idx_s2(1)):idx_s2(2),:)=[];
%        end
%        
%    else %leave while loop
%       idx_s2=[]; 
%    end
%     
%    %clear statements
%    clear idx_a1_tmp; clear idx_a1; clear idx_a2_tmp; clear idx_a2; clear sort_ang_arr_2_tmp;
%    clear idx_internal_tmp; clear sort_ang_arr_3_tmp;
%     
%    
%    %clear statements
%    clear bound_sel_2; clear dist_out_to_center; clear ang_out; clear min_ang_out; clear max_ang_out;
%    
% end
% 
% 
% %plot(bound_sel_1(:,1),bound_sel_1(:,2),'m+','MarkerSize',12,'LineWidth',1.5);
% 
