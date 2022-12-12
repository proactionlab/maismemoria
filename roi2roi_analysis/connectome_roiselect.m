function [pproisel,pproiselfdr,labels] = connectome_roiselect(outdir,pp,roislin,roiscol,names,varargin)

[pn,~,~] = fileparts(outdir);
figoutdir = [pn,filesep,'figures'];

if ~ exist(figoutdir,'dir')
    mkdir(figoutdir)
end

roislin_orig = roislin;
roiscol_orig = roiscol;

roislin = sort(roislin);
roiscol = sort(roiscol);


pproisel = nan2num(pp)+nan2num(pp');

pproisel(logical(eye(size(pp)))) = nan;

dellin = 1:size(pp,1);
dellin(roislin) = [];
pproisel(dellin,:) = [];

delcol = 1:size(pp,2);
delcol(roiscol) = [];
pproisel(:,delcol) = [];

eltodel = [];
auxdiag = [];
for i = 1:length(roislin)
    for j = 1:length(roiscol)
        if roislin(i) == roiscol(j)
            auxdiag = [auxdiag;[i,j]];
            auxellin = (i:length(roislin))';
            auxelcol = j*ones(length(auxellin),1);
            eltodel = [eltodel;[auxellin,auxelcol]];
        end
    end
end

if isempty(eltodel)
    pproiselclean = pproisel(:);
    pproiselcleanfdr = mafdr(pproiselclean,'BHFDR','true');
    pproiselfdr = reshape(pproiselcleanfdr,size(pproisel));
else
    indauxdiag = sub2ind(size(pproisel),auxdiag(:,1),auxdiag(:,2));
    indtodel = sub2ind(size(pproisel),eltodel(:,1),eltodel(:,2));
    pproiselclean = pproisel;
    pproiselclean(indtodel) = [];


    pproiselcleanfdr = mafdr(pproiselclean,'BHFDR','true');

    for i = indtodel'
        pproiselcleanfdr = [pproiselcleanfdr(1:i-1),nan,pproiselcleanfdr(i:end)];
    end
    pproiselfdr = reshape(pproiselcleanfdr,size(pproisel));

    for z = 1:size(eltodel,1)

        i = eltodel(z,1);
        j = eltodel(z,2);

        pplin = roislin(i);
        ppcol = roiscol(j);

        pproisellin = find(roislin==ppcol);
        pproiselcol = find(roiscol==pplin);

        pproiselfdr(i,j) = pproiselfdr(pproisellin,pproiselcol);
    end
end


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

    pproisel = pproisel(l,c);
    pproiselfdr = pproiselfdr(l,c);
    labels.xlabels = names(roiscol_orig);
    labels.ylabels = names(roislin_orig);
end


save([outdir,filesep,'conectomesroisel.mat'],...
    'pproisel','pproiselfdr','labels');