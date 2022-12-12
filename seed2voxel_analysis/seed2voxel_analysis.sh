#!/bin/bash

# Set inputs:
preprocdir=/media/andre/data/data_transfer/maismemoria/bids/derivatives/aromadenoised_csf_wm_6rp_smooth
outdir=/media/andre/data/data_transfer/maismemoria/processing/neurosynth
fslglmdir=${outdir}/fsl_analysis/seedtovoxel
brainmaskpath=${fslglmdir}/sub-all_ses-all_task-rest_space-MNI152NLin2009cAsym_desc-aseg_dseg_Cerebral_Cortex.nii

baseboldname=_task-rest_space-MNI152NLin2009cAsym_desc-preproc_bold_smooth-6mm_02P-aroma-denoised


if [ ! -d ${outdir} ]; then
mkdir -p ${outdir}
fi

if [ ! -d ${fslglmdir} ]; then
mkdir -p ${fslglmdir}
fi

seedlist=("Left_Hippocampus" \
"Right_Hippocampus")

seedbasename=("episodic_memory_uniformity-test_z_FDR_0.01_mni2009casym4mm_mask_" \
"episodic_memory_uniformity-test_z_FDR_0.01_mni2009casym4mm_mask_")

seedcount=-1
for seed in ${seedlist[@]}
do
    seedcount=$(( seedcount + 1 ))
    for subject in $(seq -f "%02g" 55 57)
    do
        echo Seed2voxel on subject ${subject} seed ${seed}...
        for session in $(seq -f "%02g" 1 1)
        do
            preprocdatapath="${preprocdir}/sub-${subject}/ses-${session}\
            /sub-${subject}_ses-${session}${baseboldname}.nii.gz"
            # remove blanck spaces
            preprocdatapath="$(echo -e "${preprocdatapath}" | tr -d '[:space:]')"
   
            seedmaskpath="${outdir}/rois/${seedbasename[$seedcount]}${seed}.nii"
            # remove blanck spaces
            seedmaskpath="$(echo -e "${seedmaskpath}" | tr -d '[:space:]')" 
            
            glmoutdatapath="${fslglmdir}\
            /`basename $preprocdatapath .nii.gz`_seed-${seed}.nii.gz"
            # remove blanck spaces
            glmoutdatapath="$(echo -e "${glmoutdatapath}" | tr -d '[:space:]')" 
            
            glmdesignpath="${fslglmdir}/`basename $glmoutdatapath .nii.gz`.mat"
            # remove blanck spaces
            glmdesignpath="$(echo -e "${glmdesignpath}" | tr -d '[:space:]')"
            
            
            #Get mean time series from mask
            fslmeants -i ${preprocdatapath} -o ${glmdesignpath} -m ${seedmaskpath}

            #Apply GLM on the mean time series
            fsl_glm -i ${preprocdatapath} -d ${glmdesignpath} -o ${glmoutdatapath} -m ${brainmaskpath} --demean 

        done
    done
done

# Run randomise

tmpdir=${fslglmdir}/tmp
if [ ! -d ${tmpdir} ]; then
mkdir -p ${tmpdir}
fi

if [ ! -d ${fslglmdir}/randomise ]; then
mkdir -p ${fslglmdir}/randomise
fi

tdcsgrouplist="cerebellum
dlpfc
sham
wlist"

for tdcsgroup in ${tdcsgrouplist}
do
    if [ "$tdcsgroup" = "cerebellum" ]; then
        subjectlist=$(seq -f "%02g" 01 14)
    elif [ "$tdcsgroup" = "dlpfc" ]; then
        subjectlist=$(seq -f "%02g" 15 28)
    elif [ "$tdcsgroup" = "sham" ]; then
        subjectlist=$(seq -f "%02g" 29 41)
    elif [ "$tdcsgroup" = "wlist" ]; then
        subjectlist=$(seq -f "%02g" 42 54)
    fi
    
    for seed in ${seedlist[@]}
    do
        echo Randomise on group ${tdcsgroup} seed ${seed}...
        
        
        posbtprepath="${fslglmdir}/sub-${tdcsgroup}_ses-posbtpre\
        ${baseboldname}_seed-${seed}.nii.gz"
        # remove blanck spaces
        posbtprepath="$(echo -e "${posbtprepath}" | tr -d '[:space:]')"
        
        fupbtprepath="${fslglmdir}/sub-${tdcsgroup}_ses-fupbtpre\
        ${baseboldname}_seed-${seed}.nii.gz"
        # remove blanck spaces
        fupbtprepath="$(echo -e "${fupbtprepath}" | tr -d '[:space:]')"
                
        prebtpospath="${fslglmdir}/sub-${tdcsgroup}_ses-prebtpos\
        ${baseboldname}_seed-${seed}.nii.gz"
        # remove blanck spaces
        prebtpospath="$(echo -e "${prebtpospath}" | tr -d '[:space:]')"
        
        prebtfuppath="${fslglmdir}/sub-${tdcsgroup}_ses-prebtfup\
        ${baseboldname}_seed-${seed}.nii.gz"
        # remove blanck spaces
        prebtfuppath="$(echo -e "${prebtfuppath}" | tr -d '[:space:]')"
            
        for subject in ${subjectlist}
        do
            glmprepath="${fslglmdir}\
            /sub-${subject}_ses-01${baseboldname}_seed-${seed}.nii.gz"
            # remove blanck spaces
            glmprepath="$(echo -e "${glmprepath}" | tr -d '[:space:]')"
            
            glmpospath="${fslglmdir}\
            /sub-${subject}_ses-02${baseboldname}_seed-${seed}.nii.gz"
            # remove blanck spaces
            glmpospath="$(echo -e "${glmpospath}" | tr -d '[:space:]')"
            
            glmfuppath="${fslglmdir}\
            /sub-${subject}_ses-03${baseboldname}_seed-${seed}.nii.gz"
            # remove blanck spaces
            glmfuppath="$(echo -e "${glmfuppath}" | tr -d '[:space:]')"
            
            echo "$glmpospath"
            fslmaths $glmpospath -sub ${glmprepath} ${tmpdir}/sub-${subject}_posbtpre.nii.gz
            fslmaths $glmfuppath -sub ${glmprepath} ${tmpdir}/sub-${subject}_fupbtpre.nii.gz
            fslmaths $glmprepath -sub ${glmpospath} ${tmpdir}/sub-${subject}_prebtpos.nii.gz
            fslmaths $glmprepath -sub ${glmfuppath} ${tmpdir}/sub-${subject}_prebtfup.nii.gz
        done

        fslmerge -t ${posbtprepath} ${tmpdir}/sub-*_posbtpre.nii.gz
        fslmerge -t ${fupbtprepath} ${tmpdir}/sub-*_fupbtpre.nii.gz
        fslmerge -t ${prebtpospath} ${tmpdir}/sub-*_prebtpos.nii.gz
        fslmerge -t ${prebtfuppath} ${tmpdir}/sub-*_prebtfup.nii.gz

        rm ${tmpdir}/*
        
        randomposbtprepath="${fslglmdir}/randomise/\
        `basename $posbtprepath .nii.gz`_randomise-5000.nii.gz"
        randomposbtprepath="$(echo -e "${randomposbtprepath}" | tr -d '[:space:]')"
        
        randomfupbtprepath="${fslglmdir}/randomise/\
        `basename $fupbtprepath .nii.gz`_randomise-5000.nii.gz"
        randomfupbtprepath="$(echo -e "${randomfupbtprepath}" | tr -d '[:space:]')"
        
        randomprebtpospath="${fslglmdir}/randomise/\
        `basename $prebtpospath .nii.gz`_randomise-5000.nii.gz"
        randomprebtpospath="$(echo -e "${randomprebtpospath}" | tr -d '[:space:]')"
        
        randomprebtfuppath="${fslglmdir}/randomise/\
        `basename $prebtfuppath .nii.gz`_randomise-5000.nii.gz"
        randomprebtfuppath="$(echo -e "${randomprebtfuppath}" | tr -d '[:space:]')"
        
        
        
        # Pos vs Pre
        randomise -i ${posbtprepath} -o ${randomposbtprepath} -1 -m ${brainmaskpath} -n 5000 --uncorrp -T &
        
        # Fup vs Pre
        randomise -i ${fupbtprepath} -o ${randomfupbtprepath} -1 -m ${brainmaskpath} -n 5000 --uncorrp -T &
                
        # Pre vs Pos
        randomise -i ${prebtpospath} -o ${randomprebtpospath} -1 -m ${brainmaskpath} -n 5000 --uncorrp -T &
        
        # Pre vs Fup
        randomise -i ${prebtfuppath} -o ${randomprebtfuppath} -1 -m ${brainmaskpath} -n 5000 --uncorrp -T &
        
        wait
 
    done
done

rm -r ${tmpdir}
