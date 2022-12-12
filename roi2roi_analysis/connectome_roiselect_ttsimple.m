function matroisel = connectome_roiselect_ttsimple(outdir,mat,roislin,roiscol,names,varargin)

roislin_orig = roislin;
roiscol_orig = roiscol;

roislin = sort(roislin);
roiscol = sort(roiscol);


matroisel = nan2num(mat)+nan2num(mat');

matroisel(logical(eye(size(mat)))) = nan;

dellin = 1:size(mat,1);
dellin(roislin) = [];
matroisel(dellin,:) = [];

delcol = 1:size(mat,2);
delcol(roiscol) = [];
matroisel(:,delcol) = [];


if isempty(varargin)
    labels.xlabels = names(roiscol);
    labels.ylabels = names(roislin);    
else
    
    c = zeros(size(roiscol_orig));
    l = zeros(size(roislin_orig));
    for k = 1:length(roiscol_orig)
        c(k) = find (roiscol == roiscol_orig(k));
    end
    
    for w = 1:length(roislin_orig)
        l(w) = find (roislin == roislin_orig(w));
    end
    
    matroisel = matroisel(l,c);
    labels.xlabels = names(roiscol_orig);
    labels.ylabels = names(roislin_orig);
end
