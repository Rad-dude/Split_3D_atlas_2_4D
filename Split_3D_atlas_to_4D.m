%% Split any 3D atlas to 4D
% Radwan 08/01/2019


%% Part 1 Define some stuff

clear all;
clc

dir_main = '/Volumes/LaCie/MTLE_HS/templates';
atlas_labels = [dir_main filesep 'aal_atlas.txt'];
atlas_nii = [dir_main filesep 'aal_atlas.nii'];
atlas_dir_4D = [dir_main filesep 'aal_4D'];

poolobj = gcp('nocreate');
delete(poolobj)
parpool(4);
%% Part 2
% loop to get your labels and indices from the labels.txt file (hopefully
% this is only 1 column with the indices representing the image intensity of each
% label

labels = fopen('aal_atlas.txt');
lwip = textscan(labels,'%d %s', 'delimiter','.');
fclose(labels);
indices = lwip{1};
names = lwip{2};

clear aal;
aal = struct([]);

for i = 1:size(indices,1)
    aal(i).index = (lwip{1}(i));
    aal(i).name = strrep(names(i), ' ', '_'); 
    aal(i).name = char(strtok(aal(i).name, '('));
    aal(i).lt  = char(string((double(aal(i).index)) - 0.5));
    aal(i).ut = char(string((double(aal(i).index)) + 0.5));
%     aal(i).index = (aal(i).index);
%     aal(i).name = (aal(i).name);
end


%% Part 3 
% use fslroi in a for loop to split this 3D atlas into a 4D image

mkdir(atlas_dir_4D);

parfor i = 1:size(aal,2)
    
    % need to add values for min. t.dim and size in t.dim to fslroi
    % afterwards we will need fslmerge to produce a 4D nii
    unix(['source ~/.bash_profile ;  fslmaths ' atlas_nii ' -thr ' aal(i).lt ' -uthr '  aal(i).ut ' -bin ' atlas_dir_4D filesep 'aal_4D_' aal(i).name '.nii.gz ']);
    % If you want them smoothed just add a -s 2 or something.
    
end

    aal_4D_nii = ([dir_main filesep 'aal_4D_complete.nii']);
    new_order = sort({aal(:).name});
    sort_aal = fopen([dir_main filesep 'aal_sorted.txt'] ,'w');
    fprintf(sort_aal,'%s\n',new_order{:});
    fclose(sort_aal);
    unix(['source ~/.bash_profile ; fslmerge -t ' aal_4D_nii ' ' atlas_dir_4D filesep '*aal_4D_*']); 


poolobj = gcp('nocreate');
delete(poolobj)
