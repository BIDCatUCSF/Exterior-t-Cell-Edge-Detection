function[]=stack_ims(file_1,path_1,numb_ims,gr_button)

%removing sections of the filename
if numel(file_1)<10 
    file_pre=file_1(1:((numel(file_1))-6))

    %getting the index of the initial image
    l_file=numel(file_1);
    num_start=str2num(file_1(l_file-5:l_file-3))
    
elseif numel(file_1)>10 && numel(file_1)<=21
    
    %file prefix
    file_pre=file_1(1:((numel(file_1))-6))
    
     l_file=numel(file_1);
    num_start=str2num(file_1(l_file-5:l_file-3))
    
else
    
    %removing sections of the filename
    file_pre=file_1(1:((numel(file_1))-8));
    
    %getting the index of the initial image
    l_file=numel(file_1);
    num_start=str2num(file_1(l_file-7:l_file-4))

end

%starting value
if num_start==0
    num_start=1;
end

%ending value
num_end=numb_ims-num_start+1;

%counter
count=1;

%pre-allocating
max_arr=zeros(numb_ims,1);
max_arr=double(max_arr);

%reading in the images
for i=num_start:num_end
    
    if numel(file_1)<10
        
        %reading image
        i1=imread(strcat(path_1,file_pre,num2str(i),'.tif'));
        
    elseif numel(file_1)>10 && numel(file_1)<=21
        
         %reading image
        i1=imread(strcat(path_1,file_pre,num2str(i),'.tif'));
        
    else
        
        if i<=10
            i1imread(strcat(path_1,file_pre,'000',num2str(i),'.tif'));
        elseif i>10 && i<=100
            i1=imread(strcat(path_1,file_pre,'00',num2str(i),'.tif'));
        else
            i1=imread(strcat(path_1,file_pre,'0',num2str(i),'.tif'));
        end
        
    end
    
    %pre-allocating for speed
    if count==1
       dim1=size(i1,1);
       dim2=size(i1,2);
       
       big_stack=zeros(dim1,dim2,numb_ims);
       
    end
    
    %maximum array
    max_arr(count,1)=max(i1(1:(dim1*dim2)));
    
    %making the stack
    big_stack(:,:,count)=i1;
    
    %iterate counter
    count=count+1;
    
    %clear statements
    clear i1;
    
end

%absolute max
abs_max=max(max_arr(:,1))

%max intensity projection
create_max_proj(big_stack,abs_max,gr_button);

