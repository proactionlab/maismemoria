%%
%--------------------------------------------------------------------------
% Running processing functions
outdir = '/media/andre/data/data_transfer/maismemoria/processing/neurosynth';
if ~isfolder(outdir)
   mkdir(outdir)
end

connectome_generator

sess = {'pre';'pos';'fup'};
cond = {'cerebellum';'dlpfc';'sham';'wlist'};
condidx = {1:14,15:28,29:41,42:54};
h1 = {'posbtpre','fupbtpre'};

for ss = 1:length(sess)
    for c = 1:length(cond)
        for s = 1:length(condidx{c})
            group{ss}{c}{s} = [outdir,'/connectomes/connectome_sub-',...
                sprintf('%02d',condidx{c}(s)),'_sess-',sprintf('%02d',ss),'.mat'];
        end
        
        if ss > 1
            r2routdir = [outdir,'/stats/connectome_analysis/roi2roi_',cond{c},'_',h1{ss-1}];
            % path to the file containing the rows (roislin_idx) and columns (roiscol_idx) to keept
            roiselpath = '/media/andre/data/data_transfer/maismemoria/processing/neurosynth/stats/connectome_analysis/roisel_idx.mat';
            connectome_stats(r2routdir,group{ss}{c}, group{1}{c},roiselpath)
        end
    end
end

disp('DONE!!!')


