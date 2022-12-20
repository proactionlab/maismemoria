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

%% Non FA tbss
RunTBSS_nonFA(TBSS_Path)
