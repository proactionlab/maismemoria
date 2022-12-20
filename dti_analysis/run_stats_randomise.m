clear all
close all
clc

addpath(genpath('lib'))
mainpath = pwd;
%% Specify Processing Options
Options.ConvertFormat = 'nii.gz';

%% Setup TBSS working dir
TBSS_Path = '';
[AllTBSS_Paths] = GetTBSS_Paths(TBSS_Path);

%% Extract info
ConfigDesign = MakeConfigDesign(AllTBSS_Paths,'Single-Group-Paired-Difference');

%% Treat data to later compute the statistics
SplitDiffMerge_v2(AllTBSS_Paths,Options,ConfigDesign)

%% Run Randomise :
labelNumVec = [6,35,36,37,38,45,46]; % Body Fornix, Cingulum R and L, Cingulum Hip R and L, Uncinate
Label = 'Fornix_Cing_Unc';
clobber = true;
[AllRandomisePath] = randomise_psom(AllTBSS_Paths,labelNumVec,5000,clobber,Label);


