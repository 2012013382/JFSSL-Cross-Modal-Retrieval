function [MAP_image_query, MAP_text_query] = get_MAP_result(data, I_te, T_te, W_image, W_text...
    ,train_or_test)
%Get MAP result.
%Return MAP_image and MAP_text.
if train_or_test == 0
    DATA_NUM = 2173;
else
    DATA_NUM = 693;
end
query_similarity_M = zeros(DATA_NUM, DATA_NUM);
for i = 1:DATA_NUM
   for j = 1:DATA_NUM
      query_similarity_M(i, j) = cosin_d(I_te(i, :) * W_image, T_te(j, :) * W_text);
   end
end


%Sort query similarity matrix.
[~, image_similarity_index_M] = sort(query_similarity_M, 2, 'descend');
[~, text_similarity_index_M] = sort(query_similarity_M, 1, 'descend');

%Get image query MAP.
image_AP = zeros(DATA_NUM, 1);
image_AP_count = zeros(DATA_NUM, 1);
image_AP_count(1:DATA_NUM, 1) = 1;
fprintf('Calculating MAP of image query...\n');
ClassInd = textread('wikipedia_info/trainset_txt_img_cat.list','%s','delimiter','\n');
baseDir = './wikipedia_dataset';

for i = 1:DATA_NUM
    %new added code
    temp = regexp(ClassInd(i),'\t','split');
    image = [temp{1}{2},'.jpg'];
    text = [temp{1}{1},'.xml'];
    fprintf(['This is our image input: ',image,'\n']);
    imageDir=[baseDir,'/images'];
    subdir=dir(imageDir);
    for x = 1:length(subdir)
        if(isequal(subdir(x).name,'.')||...
                isequal(subdir(x).name,'..')||...
                ~subdir(x).isdir)
            continue;
        end
        subdirpath=fullfile(imageDir,subdir(x).name,image);
        dat=dir(subdirpath);
        for y=1:length(dat)
            if(~dat(y).isdir)
                imshow(subdirpath);
            end
        end
    end
    pause();
    fprintf(['This is the corresponding text: ',text,'\n']);
    textDir=fullfile(baseDir,'texts');
    temp_t=xml2struct(fullfile(textDir,text));
    disp(temp_t.document.text.Text);
    pause();
    for j = 1:DATA_NUM
        if train_or_test == 0
            if data.train(i, 1) == data.train(image_similarity_index_M(i, j), 1)
                image_AP(i, 1) = image_AP(i, 1) + image_AP_count(i, 1) / j;
                image_AP_count(i, 1) = image_AP_count(i, 1) + 1;
            end
        elseif train_or_test == 1
            if data.test(i, 1) == data.test(image_similarity_index_M(i, j), 1)
                image_AP(i, 1) = image_AP(i, 1) + image_AP_count(i, 1) / j;
                image_AP_count(i, 1) = image_AP_count(i, 1) + 1;
                num = image_similarity_index_M(i,j);
                temp2 = regexp(ClassInd(num),'\t','split');
                text2 = [temp2{1}{1},'.xml'];
                fprintf(['This is we find text: ',text2,'\n']);
                textDir=fullfile(baseDir,'texts');
                temp_t=xml2struct(fullfile(textDir,text2));
                disp(temp_t.document.text.Text);
                pause();
            end
        end
    end
    image_AP(i, 1) = image_AP(i, 1) / (image_AP_count(i, 1) - 1);
end
MAP_image_query = sum(image_AP) / DATA_NUM;
fprintf('MAP of image query calculating finished!\n');
%Get text query MAP.
text_AP = zeros(DATA_NUM, 1);
text_AP_count = zeros(DATA_NUM, 1);
text_AP_count(1:DATA_NUM, 1) = 1;
fprintf('Calculating MAP of text query...\n');
for j = 1:DATA_NUM
    temp = regexp(ClassInd(j),'\t','split');
    image = [temp{1}{2},'.jpg'];
    text = [temp{1}{1},'.xml'];
    fprintf(['This is our corresponding image: ',image,'\n']);
    imageDir=[baseDir,'/images'];
    subdir=dir(imageDir);
    for x = 1:length(subdir)
        if(isequal(subdir(x).name,'.')||...
                isequal(subdir(x).name,'..')||...
                ~subdir(x).isdir)
            continue;
        end
        subdirpath=fullfile(imageDir,subdir(x).name,image);
        dat=dir(subdirpath);
        for y=1:length(dat)
            if(~dat(y).isdir)
                imshow(subdirpath);
            end
        end
    end
    pause();
    fprintf(['This is our input text: ',text,'\n']);
    textDir=fullfile(baseDir,'texts');
    temp_t=xml2struct(fullfile(textDir,text));
    disp(temp_t.document.text.Text);
    pause();
    for i = 1:DATA_NUM
        if train_or_test == 0
            if data.train(j, 1) == data.train(text_similarity_index_M(i, j), 1)
                text_AP(j, 1) = text_AP(j, 1) + text_AP_count(j, 1) / i;
                text_AP_count(j, 1) = text_AP_count(j, 1) + 1;
            end
        elseif train_or_test == 1
            if data.test(j, 1) == data.test(text_similarity_index_M(i, j), 1)
                text_AP(j, 1) = text_AP(j, 1) + text_AP_count(j, 1) / i;
                text_AP_count(j, 1) = text_AP_count(j, 1) + 1;
                num = image_similarity_index_M(i,j);
                temp2 = regexp(ClassInd(num),'\t','split');
                image2 = [temp2{1}{2},'.jpg'];
                fprintf(['This is we find image: ',image2,'\n']);
                imageDir=[baseDir,'/images'];
                subdir=dir(imageDir);
                for x = 1:length(subdir)
                    if(isequal(subdir(x).name,'.')||...
                            isequal(subdir(x).name,'..')||...
                            ~subdir(x).isdir)
                        continue;
                    end
                    subdirpath=fullfile(imageDir,subdir(x).name,image);
                    dat=dir(subdirpath);
                    for y=1:length(dat)
                        if(~dat(y).isdir)
                            imshow(subdirpath);
                        end
                    end
                end
                pause();
            end
        end
    end
    text_AP(j, 1) = text_AP(j, 1) / (text_AP_count(j, 1) - 1);
end
MAP_text_query = sum(text_AP) / DATA_NUM;

fprintf('MAP of text query calculating finished!\n');