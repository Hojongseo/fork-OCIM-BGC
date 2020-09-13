clc; clear all; close all
global GC GO 
on   = true    ; off = false    ;
spd  = 24*60^2 ; spa  = 365*spd ;
% addpath according to opterating system
if ismac 
    addpath('~/Dropbox/myfunc'     )
    addpath('~/Documents/DATA/'    )
    addpath('~/Documents/DATA/OCIM')
elseif isunix
    addpath('/DFS-L/DATA/primeau/weilewang/my_func/'  )
    addpath('/DFS-L/DATA/primeau/weilewang/DATA/'     )
    addpath('/DFS-L/DATA/primeau/weilewang/DATA/OCIM2')
end
format long
%
Cmodel  = on ; 
Omodel  = off ; 
Simodel = off ;
%
GridVer   = 91 ;
operator = 'A' ;
if GridVer == 90
    TRdivVer = 'Tv4' ;
elseif GridVer == 91 
    switch(operator)
      case 'A'
        TRdivVer = 'CTL_He'   ;
      case 'B'
        TRdivVer = 'CTL_noHe' ;
      case 'C'
        TRdivVer = 'KiHIGH_He'   ;
      case 'D'
        TRdivVer = 'KiHIGH_noHe' ;
      case 'E'
        TRdivVer = 'KvHIGH_KiLOW_He'  ;
      case 'F'
        TRdivVer = 'KvHIGH_KiLOW_noHe';
      case 'G'
        TRdivVer = 'KiLOW_He'   ;
      case 'H'
        TRdivVer = 'KiLOW_noHe' ;
      case 'I'
        TRdivVer = 'KvHIGH_He'  ;
      case 'J'
        TRdivVer = 'KvHIGH_noHe';
      case 'K'
        TRdivVer = 'KvHIGH_KiHIGH_noHe';
    end 
end 

fprintf('Transport version: % s \n', TRdivVer)
if Cmodel == on
    fprintf('---- C model is on ---- \n')
end
if Omodel == on
    fprintf('---- O model is on ---- \n')
end 
if Simodel == on
    fprintf('---- Si model is on ---- \n')
end 
fprintf('\n')
% P model parameters
par.optim     = off    ; 
par.Cmodel    = Cmodel ;
par.Omodel    = Omodel ;
par.Simodel   = Simodel;
par.opt_sigma = off ; 
par.opt_kP_T  = on ;
par.opt_kdP   = on ;
par.opt_bP_T  = on ; 
par.opt_bP    = on ;
par.opt_beta  = on ;
par.opt_alpha = on ;
% C model parameters
par.opt_bC_T  = on ;
par.opt_bC    = on ; 
par.opt_d     = on ;
par.opt_kC_T  = on ;
par.opt_kdC   = on ; 
par.opt_RR    = on ; 
par.opt_cc    = on ;
par.opt_dd    = on ;
% O model parameters
par.opt_O2C_T = on ;
par.opt_rO2C  = on ;
par.opt_O2P_T = on ; 
par.opt_rO2P  = on ; 
% Si model parameters
par.opt_dsi   = on  ;
par.opt_at    = off ;
par.opt_bt    = on  ;
par.opt_aa    = on  ;
par.opt_bb    = on  ;
%
% save results 
% ATTENTION: please change this direcrtory to where you wanna
% save your output files
if ismac
    output_dir = sprintf('~/Documents/CP-model/MSK%2d/',GridVer); 
elseif isunix
    output_dir = sprintf(['/DFS-L/DATA/primeau/weilewang/COP4WWF/' ...
                        'MSK%2d/'],GridVer);
end
VER = strcat(output_dir,TRdivVer);
% Creat output file names based on which model(s) is(are) optimized
if (Cmodel == off & Omodel == off & Simodel == off)
    fname = strcat(VER,'_P');
elseif (Cmodel == on & Omodel == off & Simodel == off)
    fname = strcat(VER,'_PC');
elseif (Cmodel == on & Omodel == on & Simodel == off)
    fname = strcat(VER,'_PCO');
elseif (Cmodel == on & Omodel == off & Simodel == on)
    fname = strcat(VER,'_PCSi');
elseif (Cmodel == on & Omodel == on & Simodel == on)
    fname = strcat(VER,'_PCOSi');
end

par.fname = fname ; 
% load optimal parameters if they exist
fxhat     = strcat(fname,'_xhat.mat');
par.fxhat = fxhat ; 
%
if GridVer == 90
    load transport_v4.mat grid M3d TR
    load M3d90x180x24v2.mat MSKS 
    load Sobs_90x180x24.mat
    load tempobs_90x180x24.mat
    load po4obs_90x180x24.mat       % WOA PO4 observation
    load Siobs_90x180x24.mat Siobs
    %
    load DICant_90x180x24.mat
    load GLODAPv2_90x180x24raw.mat
    load splco2_mod_monthly.mat     % monthly CO2 data
    load co2syspar90.mat co2syspar
    load cbpm_npp_annual_90x180.mat
    load kw660_90x180.mat
    %
    grd = grid ;

elseif GridVer == 91
    OperName = sprintf('OCIM2_%s',TRdivVer);
    load(OperName,'output') ;
    load M3d91x180x24.mat MSKS 
    load Sobs_91x180x24.mat
    load po4obs_91x180x24.mat % WOA PO4 observation
    load tempobs_91x180x24.mat
    load Siobs_91x180x24.mat Siobs
    %
    load DICant_91x180x24.mat
    load GLODAPv2_91x180x24raw.mat
    load splco2_mod_monthly % monthly CO2 data
    load co2syspar91.mat co2syspar
    load cbpm_npp_annual_91x180.mat
    load kw660_91x180.mat
    %
    M3d = output.M3d;
    grd = output.grid;
    TR  = output.TR/spa;
end

load(fname)
load(fxhat) 
% get rid of arctice o2 observations
ARC  = MSKS.ARC;
iarc = find(ARC(:));
o2raw(iarc)   = nan ;
dicraw(iarc)  = nan ;
po4raw(iarc)  = nan ;
sio4raw(iarc) = nan ; 
iwet = find(M3d(:)) ;
nwet = length(iwet) ;
dVt  = grd.DXT3d.*grd.DYT3d.*grd.DZT3d;
%
[par.kw,par.P] = kw(M3d,grd);
par.Salt  = Sobs    ;
par.Temp  = tempobs ;
par.dVt   = dVt     ;
par.Kw660 = Kw660   ;
par.p4    = p4      ;
par.c2p   = 110     ;
par.M3d   = M3d     ;
par.iwet  = iwet    ;
par.nwet  = nwet    ;
par.TRdiv = -TR     ;
par.grd   = grd     ;
par.I     = speye(nwet)  ;
par.rho   = 1024.5       ; % seawater density;
permil    = par.rho*1e-3 ; % from umol/kg to mmol/m3;

par.po4obs    = po4obs  ;
par.human_co2 = DICant*permil;

% transiant CO2 concentraion;
par.year      = splco2_mod(:,1) ;
par.pco2_air  = splco2_mod(:,2) ;
par.co2syspar = co2syspar       ;

% load optimal parameters from a file
% or set them to default values 
par = SetPara(par) ;
%
% pack adjustable parameters in an array and
% assign them corresponding indices.
[p0, par] = PackPar(par) ;
%
PrintPara(p0, par) ;
% PME part;
[modT,modS] = PME(par)   ;
modT        = modT + 2   ;
par.modS    = modS       ;
par.modT    = modT       ;
par.aveT    = nanmean(modT(:,:,1:3),3) ;
par.Tz      = modT(iwet)*1e-9 ;

%%%%%%% prepare NPP for the model %%%%%%%%
par.nzo = 2 ;
par.p2c = 0.006+0.0069*po4obs ;
inan = find(isnan(npp(:)) | npp(:) < 0) ;
npp(inan) = 0 ;

% tmp = squeeze(M3d(:,:,1)) ;
% tmp(1:15,:) = nan         ; % SO
% tmp(65:78,55:125) = nan   ; % NP
% tmp(35:55,90:145) = nan   ; % EP
% itarg = find(isnan(tmp(:)))  ;
% npp(itarg) = npp(itarg)*0.5  ;
%
par.npp    = npp/(12*spd) ;
par.npp1   = (0.5*par.npp./grd.dzt(1)).*par.p2c(:,:,1) ; 
par.npp2   = (0.5*par.npp./grd.dzt(2)).*par.p2c(:,:,2) ; 
par.Lambda = M3d*0 ;
par.Lambda(:,:,1) = 1./(1e-6+po4obs(:,:,1)) ;
par.Lambda(:,:,2) = 1./(1e-6+po4obs(:,:,2)) ;

par.Lambda(:,:,3:end) = 0 ;

DIP = data.DIP ;
POP = data.POP ;
DOP = data.DOP ;

par.DIPbar = nansum(po4obs(iwet).*dVt(iwet))/nansum(dVt(iwet)) ;
[par, P ] = eqPcycle(p0, par) ;
%
pDIP = M3d+nan ;  pDIP(iwet) = P(1+0*nwet:1*nwet) ;
pPOP = M3d+nan ;  pPOP(iwet) = P(1+1*nwet:2*nwet) ;
pDOP = M3d+nan ;  pDOP(iwet) = P(1+2*nwet:3*nwet) ;
par.DIP  = pDIP(iwet) ;
nfig = 1 ;
figure(nfig)
dDIP = pDIP - data.DIP ; 
% make a zonal cross section of the age
% contourf(grd.yt,-grd.zt,squeeze(dDIP(:,170,:))',[0:10:100])
contourf(grd.yt,-grd.zt,squeeze(dDIP(:,170,:))')
% caxis([0 100])
xlabel('latitude (deg)');
ylabel('depth (m)')
t = sprintf('age x = %4.1f deg',grd.xt(1));
title(t);
colorbar

nfig = nfig + 1;
figure(nfig)
% make a zonal average of age for the Pacific basin
PAC = MSKS.PAC;
PZA = squeeze(nansum(PAC.*dDIP.*dVt,2)./sum(PAC.*dVt,2))';

contourf(grd.yt,-grd.zt,PZA); colorbar
xlabel('latitutde (deg)');
ylabel('depth (m)');
t = 'Pacific zonal average DIP anormally';
title(t)

if Cmodel == on 
    DIC = data.DIC ;
    POC = data.POC ;
    DOC = data.DOC ; 
    CaC = data.CaC ;
    
    GC = real([DIC(iwet); POC(iwet); DOC(iwet); CaC(iwet)]);
    [par, C ] = eqCcycle(p0, par) ;
    pDIC = M3d+nan ;  pDIC(iwet) = C(0*nwet+1:1*nwet) ;
    pPOC = M3d+nan ;  pPOC(iwet) = C(1*nwet+1:2*nwet) ;
    pDOC = M3d+nan ;  pDOC(iwet) = C(2*nwet+1:3*nwet) ;
    pCaC = M3d+nan ;  pCaC(iwet) = C(3*nwet+1:4*nwet) ;
    par.DIC  = DIC(iwet) ;
    par.DOC  = DOC(iwet) ;
    dDIC = pDIC - data.DIC ;
    nfig = nfig + 1;
    figure(nfig)
    % make a zonal cross section of the age
    contourf(grd.yt,-grd.zt,squeeze(dDIC(:,170,:))')
    % caxis([0 100])
    xlabel('latitude (deg)');
    ylabel('depth (m)')
    t = sprintf('age x = %4.1f deg',grd.xt(1));
    title(t);
    colorbar
    
    nfig = nfig + 1;
    figure(nfig)
    % make a zonal average of age for the Pacific basin
    PAC = MSKS.PAC;
    PZA = squeeze(nansum(PAC.*dDIC.*dVt,2)./sum(PAC.*dVt,2))';
    
    contourf(grd.yt,-grd.zt,PZA); colorbar
    xlabel('latitutde (deg)');
    ylabel('depth (m)');
    t = 'Pacific zonal average DIC anormally';
    title(t)
end

if Omodel == on 
    O2 = data.O2 ;
    GO = real(O2(iwet)) + 1e-9*randn(par.nwet,1);
    [par, O2] = eqOcycle(p0, par) ;
end
    


