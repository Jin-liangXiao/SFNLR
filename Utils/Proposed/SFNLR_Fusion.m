function [X_out] = SFNLR_Fusion(Y,P_3D,G1,G2,opts)
% Inputs:
%           Y:               LRMS image;
%           P_3D:            Histogram matched PAN image;
%           G1,G2:           Adaptive coefficients;
%           opts:            Parameters.
% Output:
%           X_out:           Pasharpened image.
% 
% Reference:
% J.-L. Xiao, T.-Z. Huang, L.-J. Deng, Z.-C. Wu, X. Wu, and G. Vivone, 
% Variational Pansharpening Based on Coefficient Estimation with Nonlocal Regression
% IEEE Trans. Geosci. Remote Sens., doi: 10.1109/TGRS.2023.3305296.
%==========================================================================
%% Initiation
maxit = opts.maxit;
tol   = opts.tol;              
Nways = opts.Nways;
sz    = opts.sz;
lambda1 = opts.lambda1;
eta_1 = opts.eta_1 ;
sf    = opts.sf;
sensor = opts.sensor;
X      = imresize(Y, sf,'bicubic');
par  = FFT_kernel(sf, sensor ,Nways);
M     = zeros(Nways);
Thet_1= zeros(Nways);   

%%
X_k = X;

for it = 1:maxit
    % update X

    for sp=1:Nways(3)

        Q1=G1.*P_3D+G2;
        FFT_Up = 2*lambda1.*fft2(Q1(:,:,sp))...
            +eta_1.*fft2(M(:,:,sp)).*par.fft_BT(:,:,sp)-fft2(Thet_1(:,:,sp)).*par.fft_BT(:,:,sp);
        FFT_Down = eta_1.*par.fft_B(:,:,sp).*par.fft_BT(:,:,sp)+2*lambda1;
        X(:,:,sp) = real(ifft2(FFT_Up./FFT_Down));
    end  
    X(X<0)=0;
    X(X>1)=1;

    % update M
    
    temp_UP  =  2*par.ST(Y)+ eta_1*par.B(X)+Thet_1;

    SST      =  zeros(sz);
    s0       =  3;
    SST(s0:sf:end,s0:sf:end) = ones(sz/sf);

    temp_DOWN=  2*SST+eta_1;
    temp_DOWN=  repmat(temp_DOWN, [1 1 Nways(3)]);
    M = temp_UP./temp_DOWN;

    %%
    Thet_1 = Thet_1+eta_1*(MTF_im(X, sensor, '', sf)-M);  
    %%
    Rel_Err = norm(Unfold(X-X_k,Nways,3) ,'fro')/norm(Unfold(X_k,Nways,3),'fro');
    X_k = X;
    if Rel_Err < tol  
        break;
    end   
end

X_out=X;
end

