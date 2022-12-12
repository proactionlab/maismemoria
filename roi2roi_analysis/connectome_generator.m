%%
rootoutdir = '/media/andre/data/data_transfer/maismemoria/processing/neurosynth/';

roisdir = [rootoutdir,'/rois'];

roisdirstruc = dir([roisdir,'/*.nii']);
rois_filename = {roisdirstruc(:).name};

pat = 'mask_';
roi_names = cell(length(rois_filename),1);
roi_masks = cell(length(rois_filename),1);
for r = 1:length(rois_filename)
    roipath = [roisdir,filesep,rois_filename{r}];
    roivol = spm_vol(roipath);
    roi_masks{r} = spm_data_read(roivol);
    
    [~,fn,~] = fileparts(rois_filename{r});
    k = strfind(fn, pat);
    roi_names{r} = fn(k+length(pat):end);
end
%%

sess = {'pre';'pos';'fup'};
nsub = [57,56,54];
 
for ss = 1:length(sess)
    for s = 1:nsub(ss)
        disp(['working on session-',num2str(ss),' subj-',num2str(s)])
        boldpath = ['/media/andre/data/data_transfer/maismemoria/',...
            'bids/derivatives/aromadenoised_csf_wm_6rp_smooth',...
            '/sub-',sprintf('%02d',s),'/ses-',sprintf('%02d',ss),...
            '/sub-',sprintf('%02d',s),'_ses-',sprintf('%02d',ss),...
            '_task-rest_space-MNI152NLin2009cAsym_desc-preproc_bold',...
            '_smooth-6mm_02P-aroma-denoised.nii.gz'];
         
        
        boldvol = spm_vol(boldpath);
        bolddata = spm_data_read(boldvol);
        
        tseries = [];
        for r = 1:length(roi_masks)
            currtseries = [];
            for i = 1:length(bolddata)
                auxdata = squeeze(bolddata(:,:,:,i));
                auxcurrtseries = auxdata(logical(roi_masks{r}));
                currtseries = [currtseries,auxcurrtseries];                
            end
            meantseries = mean(currtseries);
            
            tseries = [tseries; meantseries];
        end
        
        zconnec = nan(size(tseries,1));
        for i = 1:size(tseries,1)-1
            for j = i+1:size(tseries,1)
                r = corrcoef(tseries(i,:),tseries(j,:));
                zconnec(i,j) = atanh(r(1,2));
            end
        end
        
        connecdir = [rootoutdir,'/connectomes'];
        if ~isfolder(connecdir)
            mkdir(connecdir)
        end
        
        
        save([connecdir,'/connectome_sub-',...
            sprintf('%02d',s),'_sess-',sprintf('%02d',ss),'.mat'],...
            'zconnec','tseries','roi_names','roi_masks')        
    end
end