#!/bin/bash
#
#SBATCH -J fmriprep
#SBATCH --time=24:00:00
#SBATCH -n 1
#SBATCH --cpus-per-task=16
#SBATCH --mem-per-cpu=4000
#SBATCH -p normal
# Outputs ----------------------------------------------------------------------
#SBATCH -o /home/contentmap/shared/data/maismemoria/log/%x-%A-%a.out
#SBATCH -e /home/contentmap/shared/data/maismemoria/log/%x-%A-%a.err
#SBATCH --mail-user=peres.asc@gmail.com
#SBATCH --mail-type=ALL

#-------------------------------------------------------------------------------
# Import the Singularity module
module load Singularity

# Set the study folders
export STUDY=/home/contentmap/shared/data/maismemoria
# set FS_LICENSE
export SINGULARITYENV_FS_LICENSE=$HOME/.freesurfer.txt
# Designate a templateflow bind-mount point
export SINGULARITYENV_TEMPLATEFLOW_HOME="/templateflow"

FMRIPREP_SIMG=/home/contentmap/shared/fmriprep-simgs/fmriprep-20.1.1.simg
TEMPLATEFLOW_HOST_HOME=$HOME/.cache/templateflow # templateflow folder.
FMRIPREP_HOST_CACHE=$HOME/.cache/fmriprep

BIDS_DIR="$STUDY/bids" # folder that contains the bids data
DERIVS_DIR="$BIDS_DIR/derivatives" # fmriprep output folder
LOCAL_FREESURFER_DIR="$DERIVS_DIR/freesurfer" # freesurfer output folder
HOST_WORK="$STUDY/work" # fmriprep temp folder

#-------------------------------------------------------------------------------
# Creates the defined folders
mkdir -p ${TEMPLATEFLOW_HOST_HOME}
mkdir -p ${FMRIPREP_HOST_CACHE}
mkdir -p ${DERIVS_DIR}
mkdir -p ${LOCAL_FREESURFER_DIR}
mkdir -p ${HOST_WORK}

#-------------------------------------------------------------------------------
# Running fMRIPrep through Singularity
SINGULARITY_CMD="singularity run --cleanenv \
-B $BIDS_DIR:/data \
-B ${TEMPLATEFLOW_HOST_HOME}:${SINGULARITYENV_TEMPLATEFLOW_HOME} \
-B $HOST_WORK:/work \
-B ${LOCAL_FREESURFER_DIR}:/fsdir $FMRIPREP_SIMG"

# Parse the participants.tsv file and extract one subject ID from the line
# corresponding to this SLURM task.
subject=$( sed -n -E "$((${SLURM_ARRAY_TASK_ID} + 1))s/sub-(\S*)\>.*/\1/gp" \
${BIDS_DIR}/participants.tsv )

# Compose the command line
cmd="${SINGULARITY_CMD} /data ${DERIVS_DIR} participant \
--participant-label $subject -w /work/ -vv \
--output-spaces MNI152NLin2009cAsym anat MNI152NLin6Asym fsnative fsaverage5 \
--use-aroma --fs-subjects-dir /fsdir"

#-------------------------------------------------------------------------------
# Setup done, run the command
echo Running task ${SLURM_ARRAY_TASK_ID}
echo Commandline: $cmd
eval $cmd
exitcode=$?

#-------------------------------------------------------------------------------
# Output results to a table
echo "sub-$subject   ${SLURM_ARRAY_TASK_ID}    $exitcode" \
      >> ${SLURM_JOB_NAME}.${SLURM_ARRAY_JOB_ID}.tsv
echo Finished tasks ${SLURM_ARRAY_TASK_ID} with exit code $exitcode
exit $exitcode
