#!/bin/bash

preprocdir=/media/andre/data/data_transfer/maismemoria/bids/derivatives/fmriprep


for subject in $(seq -f "%02g" 1 54)
do
    for session in $(seq -f "%02g" 1 3)
    do
        echo Smoothing subject ${subject} session ${session}...
        
        outdatapath="${preprocdir}/sub-${subject}/ses-${session}/func\
        /sub-${subject}_ses-${session}_task-rest_space-MNI152NLin2009cAsym_\
        desc-preproc_bold_smooth-6mm.nii.gz"
        # remove blanck spaces
        outdatapath="$(echo -e "${outdatapath}" | tr -d '[:space:]')"
        
        indatapath="${preprocdir}/sub-${subject}/ses-${session}/func\
        /sub-${subject}_ses-${session}_task-rest_space-MNI152NLin2009cAsym_\
        desc-preproc_bold.nii.gz"
        # remove blanck spaces
        indatapath="$(echo -e "${indatapath}" | tr -d '[:space:]')"
        
        maskpath="${preprocdir}/sub-${subject}/ses-${session}/func\
        /sub-${subject}_ses-${session}_task-rest_space-MNI152NLin2009cAsym_\
        desc-brain_mask.nii.gz"
        # remove blanck spaces
        maskpath="$(echo -e "${maskpath}" | tr -d '[:space:]')"
        
        boldrefpath="${preprocdir}/sub-${subject}/ses-${session}/func\
        /sub-${subject}_ses-${session}_task-rest_space-MNI152NLin2009cAsym_\
        boldref.nii.gz"
        # remove blanck spaces
        boldrefpath="$(echo -e "${boldrefpath}" | tr -d '[:space:]')"
        
        
        bm=$(fslstats $indatapath -k $maskpath -p 50)
        bt=$(echo "$bm * 0.75"|bc)

        bm1=$(fslstats $boldrefpath -k $maskpath -p 50)
        bt1=$(echo "$bm * 0.75"|bc)

        #fslmaths <pre_thr_func_img> -Tmean <mean_func>
        #susan <in> <bt> <dt> <dim> <md> <n_usans> <usan1> <bt1> <output>
        susan $indatapath $bt 6 3 1 1 $boldrefpath $bt1 $outdatapath
        
    done
done

