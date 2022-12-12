#! /bin/bash

export STUDY="/media/andre/data/data_transfer/maismemoria/bids"

python -c 'import os; from fmriprep2aroma6rpdenoise import fmriprep2aroma6rpdenoise; fmriprep2aroma6rpdenoise(os.environ["STUDY"])'
