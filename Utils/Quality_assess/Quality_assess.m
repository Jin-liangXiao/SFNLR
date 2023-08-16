function Index = Quality_assess(HR_ref, HR_fusion, ratio)
%================
% This is a demo to compute pansharpening indexes
% Z.-C.Wu (UESTC)
% 2019-10-5
% ratio : GSD ratio between HRMS and LRMS images
%================
[Index.PSNR, Index.SSIM]  = Quality_ass(HR_ref * 255, HR_fusion  * 255);
[rows,cols,~] = size(HR_ref);
%Remove border from the analysis
HR_ref    = HR_ref(ratio+1:rows-ratio,ratio+1:cols-ratio,:);
HR_fusion = HR_fusion(ratio+1:rows-ratio,ratio+1:cols-ratio,:);
HR_ref(HR_ref > 1) = 1;
HR_ref(HR_ref < 0) = 0;
% maxval1 = max(Computed(:));  minval1= min(Computed(:));
% maxval2 = max(HRMS(:));  minval2= min(HRMS(:));
[PSNR, SSIM]  = Quality_ass(HR_ref * 255, HR_fusion  * 255);
Index.PSNR=roundn(PSNR,-2);
Index.SSIM=roundn(SSIM,-2);

 [angle_SAM,~]  = SAM( HR_ref, HR_fusion);
 Index.SAM      = roundn(angle_SAM,-3);
 
 SCC      = CC(HR_ref,HR_fusion);
 Index.SCC      = roundn(SCC,-3);
 
 ERGAS0    = ERGAS( HR_ref, HR_fusion, ratio);
 Index.ERGAS      = roundn(ERGAS0,-3);
 
 Q8       = Q(HR_ref,HR_fusion );
 Index.Q8      = roundn(Q8,-3);
%  Index.QAVE     = QAVE( HRMS, Computed);
%  Index.RASE     = RASE( HRMS, Computed);
%  Index.RMSE     = RMSE( HR_ref, HR_fusion );
%  index.QAVE     = q2n( HRMS,Computed,32,32);
%  index.CC          = CC( HRMS, Computed);
%  index.PSNR      = psnr(Computed, HRMS);
%  index.SSIM      = ssim(255*Computed, 255*HRMS);
end
 
