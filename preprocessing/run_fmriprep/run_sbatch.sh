#! /bin/bash

sbatch --array=1-$(( $( wc -l /home/contentmap/shared/data/maismemoria/bids/participants.tsv | cut -f1 -d' ' ) - 1 )) /home/contentmap/shared/data/maismemoria/sbatch_maismemoria.slurm
