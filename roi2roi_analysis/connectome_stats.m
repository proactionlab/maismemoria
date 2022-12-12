function connectome_stats(outdir,group1, group2,varargin)
% ==================================================
% Roi to Roi Stats
% ==================================================
%
% roi2roi_stats(rootoutdir,firstleveldir,groups)

%--------------------------------------------------------------------------
% Definitions


if ~ exist(outdir,'dir')
    mkdir(outdir)
end


[ft1, posft1, names] = connectome2featmatrix(group1);
[ft2, ~, ~] = connectome2featmatrix(group2);

labels.xlabels = names;
labels.ylabels = names;

posftidx = logical(nan2num(posft1));
r2ravg1 = mean(ft1);
r2ravgmat1 = nan(size(posft1));
r2ravgmat1(posftidx) = r2ravg1(:); 

r2ravg2 = mean(ft2);
r2ravgmat2 = nan(size(posft1));
r2ravgmat2(posftidx) = r2ravg2(:); 

r2rdif = nan(size(posft1));
r2rdif(posftidx) = r2ravg1(:) - r2ravg2(:);

[h,p,ci,stats] = ttest(ft1,ft2,'Tail','right');

pp = nan(size(posft1));
pp(posftidx) = p(:);
hh = zeros(size(posft1));
hh(posftidx) = h(:);
tt = nan(size(posft1));
tt(posftidx) = stats.tstat(:);
df = nan(size(posft1));
df(posftidx) = stats.df(:);

pfdr = mafdr(p','BHFDR','true');
ppfdr = nan(size(posft1));
ppfdr(posftidx) = pfdr(:);

pbfr = p*length(p);
pbfr(pbfr>1) = 1;
ppbfr = nan(size(posft1));
ppbfr(posftidx) = pbfr(:);

[pbhl, ~] = bonf_holm(p,.5);
ppbhl = nan(size(posft1));
ppbhl(posftidx) = pbhl(:);

save([outdir,'/conectomes.mat'],...
    'pp','ppfdr','ppbfr','ppbhl','r2ravgmat1','r2ravgmat2','names','ci','stats');


if ~isempty(varargin)
    stc = load(varargin{1});
    [pp,ppfdr,labels] = connectome_roiselect(outdir,pp,stc.roislin_idx,stc.roiscol_idx,names,1);
        
    tt = connectome_roiselect_ttsimple(outdir,tt,stc.roislin_idx,stc.roiscol_idx,names,1);
        
    df = connectome_roiselect_ttsimple(outdir,df,stc.roislin_idx,stc.roiscol_idx,names,1);
    
    r2rdif = connectome_roiselect_ttsimple(outdir,r2rdif,stc.roislin_idx,stc.roiscol_idx,names,1);
end

[lin, col] = find(ppfdr<.05);

if isempty(lin)
    notsig = 'There are no ROI to ROI connectivity differences.';
    fid = fopen([outdir,'/r2rtable.txt'],'wt');
    fprintf(fid, notsig);
    fclose(fid);
else    
    r2rtable = table;
    for i = 1:length(lin)
        r2rtable.rois(i) = {[labels.ylabels{lin(i)},' X ',labels.xlabels{col(i)}]};
        r2rtable.lin(i) = lin(i);
        r2rtable.col(i) = col(i);
        r2rtable.meandif(i) = r2rdif(lin(i),col(i));
        r2rtable.tvalue(i) = tt(lin(i),col(i));
        r2rtable.df(i) = df(lin(i),col(i));
        r2rtable.pvalue(i) = pp(lin(i),col(i));
        r2rtable.pvalue_fdr(i) = ppfdr(lin(i),col(i));    
    end
    save([outdir,'/r2rtable.mat'],'r2rtable')
    writetable(r2rtable,[outdir,'/r2rtable.txt'],'Delimiter','\t')
end