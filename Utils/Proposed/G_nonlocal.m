function [G1,G2] = G_nonlocal(Y,P_3D,Par)
% Inputs:
%           Y:            LRMS image;
%           P_3D:            Histogram matched PAN image;
%           Par:            Parameters.
% Outputs:
%           G1,G2:       Adaptive coefficients.
% 
% Reference:
% J.-L. Xiao, T.-Z. Huang, L.-J. Deng, Z.-C. Wu, X. Wu, and G. Vivone, 
% Variational Pansharpening Based on Coefficient Estimation with Nonlocal Regression
% IEEE Trans. Geosci. Remote Sens., doi: 10.1109/TGRS.2023.3305296.
%==========================================================================
%% Parameter setting
patchsize=5;
overlap=4;
K=150;
sensor=Par.sensor;
sf=4;

bparams.block_sz = [patchsize, patchsize];
bparams.overlap_sz=[overlap overlap];
[nr, nc,~]=size(P_3D);
L=size(P_3D,3);
num1=(nr-patchsize)/(patchsize-overlap)+1;
num2=(nc-patchsize)/(patchsize-overlap)+1;
bparams.block_num=[num1 num2]; 
fkmeans_omaxpt.careful = 1;
predenoised_blocks = ExtractBlocks(P_3D, bparams);
Y2=Unfold(predenoised_blocks,size(predenoised_blocks),4);
[aa ]=fkmeans(Y2,K,fkmeans_omaxpt);


XB=interp23tap(Y,sf);
PB = MTF_im(P_3D,sensor,'',sf);


block1 = ExtractBlocks(PB, bparams); 
block2 = ExtractBlocks(XB, bparams);
G_block = zeros(patchsize,patchsize,L,num1*num2);
G_block2 = zeros(patchsize,patchsize,L,num1*num2);
for band=1:L
for ii=min(aa):max(aa)
    location=find(aa==ii);
    len = length(location);
    A=block1(:,:,band,location);
    A=reshape(A,patchsize*patchsize*len,1);
    B=block2(:,:,band,location);
    B=reshape(B,patchsize*patchsize*len,1);
    h = robustfit(A,B,'ols');  
    G_block(:,:,band,location)=h(2,1).*ones(patchsize,patchsize,1,len);
    G_block2(:,:,band,location)=h(1,1).*ones(patchsize,patchsize,1,len);

end
end
G1=JointBlocks(G_block, bparams);
G2=JointBlocks(G_block2, bparams);


end

