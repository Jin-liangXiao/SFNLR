%% ================================================================
% This is the demo code for 
% "Variational Pansharpening Based on Coefficient Estimation with Nonlocal Regression"
%  by J.-L. Xiao, T.-Z. Huang, L.-J. Deng, Z.-C. Wu, X. Wu,and G. Vivone.

% If you use this code, please cite the following paper:

% J.-L. Xiao, T.-Z. Huang, L.-J. Deng, Z.-C. Wu, X. Wu, and G. Vivone, 
% Variational Pansharpening Based on Coefficient Estimation with Nonlocal Regression
% IEEE Trans. Geosci. Remote Sens., doi: 10.1109/TGRS.2023.3305296.

% =========================================================================
clear;clc
close all;
addpath(genpath(pwd));
load 'data_gf2.mat'
sensor = 'none';     
I_GT   = gt;

%% Load LR-MS image
I_LRMS = lrms;
%% Load HR-PAN image
I_PAN  = pan;


%%  Initialization

lambda1  = 0.0001;
eta_1   = 0.002;
sf      = 4;
[~,~,L]  = size(I_LRMS);
sz       = size(I_PAN);
Nways    = [sz, L];
opts = [];
opts.lambda1 = lambda1;
opts.eta_1    = eta_1;
opts.sf     = sf;
opts.Nways  = Nways;
opts.sz     = sz;
opts.tol    = 2*1e-5;   
opts.maxit  = 100;
opts.sensor = sensor;
%%
P_3D = hist_mapping(I_LRMS, I_PAN, 4, [64 64]);

[G1,G2]=G_nonlocal(I_LRMS,P_3D,opts);
X_est=SFNLR_Fusion(I_LRMS,P_3D,G1,G2,opts);

%% Plotting
close all
location = [65 85 5 25];
showRGB4(gt, gt, location);title('Orginal');
showRGB4(gt, X_est, location);title('Fusion by SFNLR');
%% Show Metrics
Eva_Xfin   = Quality_assess(gt, X_est, sf);
fprintf('SFNLR_test      PSNR: %.4f   SSIM: %.4f   SAM: %.4f   SCC: %.4f   ERGAS: %.4f   Q8: %.4f\n',...
     Eva_Xfin.PSNR,Eva_Xfin.SSIM,Eva_Xfin.SAM,Eva_Xfin.SCC,Eva_Xfin.ERGAS,Eva_Xfin.Q8)
