function [ rstp_result ] = rstp_post_batch(bolddir,t1dir, t2dir, t2stardir, resultsdir )
% move the batch results to resultdir 
% ${BOLDDIR} ${T1DIR} ${T2DIR} ${T2starDIR}  ${RESULTSDIR}
% to prepare the results tarball
diary 'rstp_post_batch.log';
% Move the processed files into destdir for tarball archiving
BOLD_dest   = fullfile(resultsdir,'processed_fMRI');
struct_dest = fullfile(resultsdir,'processed_structural');
cd(resultsdir);
try
    % Finally, create the folder if it doesn't exist already.
    if ~exist(BOLD_dest)
            mkdir(BOLD_dest);
    end
    if ~exist(struct_dest)
            mkdir(struct_dest);
    end
    
    % 1- getresults from EPIBOLD and step 1
    cd(bolddir);
    
    result1 = ls('rp*.txt');
    movefile(result1,BOLD_dest);
    
    % 2- getresults from EPIBOLD and step 2
    result2 = strsplit(ls('a*.nii'));
    [nrows,ncols] = size(result2);
    for col = 1:ncols-1
          movefile(result2{col},BOLD_dest);
    end
    
    % 3 - other results from epibold
    result3 = ls('s6wa*.nii');
    movefile(result3,BOLD_dest);
    
    result4 = ls('wa*.nii');
    movefile(result4,BOLD_dest);
    
    % -----------------------
    % 4 - from T1 directory
    % -----------------------
    cd(t1dir);
    
    % results of segmentation of T1
    c1result = ls('c1*.nii');
    c2result = ls('c2*.nii');
    c3result = ls('c3*.nii');
    c4result = ls('c4*.nii');
    c5result = ls('c5*.nii');
    c6result = ls('c6*.nii');
    
    movefile(c1result,struct_dest);
    movefile(c2result,struct_dest);
    movefile(c3result,struct_dest);
    movefile(c4result,struct_dest);
    movefile(c5result,struct_dest);
    movefile(c6result,struct_dest);
    
    % results of normalized segmented of T1
    wc1result = ls('wc1*.nii');
    wc2result = ls('wc2*.nii');
    wc3result = ls('wc3*.nii');
    wmresult = ls('wm*.nii');
    
    movefile(wc1result,struct_dest);
    movefile(wc2result,struct_dest);
    movefile(wc3result,struct_dest);
    movefile(wmresult,struct_dest);
    
    % results of bias corrected normalized segmented of T1
    mwc1result = ls('mwc1*.nii');
    mwc2result = ls('mwc2*.nii');
    mwc3result = ls('mwc3*.nii');
    
    movefile(mwc1result,struct_dest);
    movefile(mwc2result,struct_dest);
    movefile(mwc3result,struct_dest);
    
    % resullts of other bias corrected
    mresult = ls('m*.nii');
    movefile(mresult,struct_dest);
    
    % resullts of deformation
    y_result = ls('y_*.nii');
    movefile(y_result,struct_dest);
    
    % resullts of inverse deformation
    iy_result = ls('iy_*.nii');
    movefile(iy_result,struct_dest);
    
    % results of smoothed normalized segmented of T1
    s6wc1result = ls('s6wc1*.nii');
    s6wc2result = ls('s6wc2*.nii');
    s6wc3result = ls('s6wc3*.nii');
    s6wmresult = ls('s6wm*.nii');
    
    movefile(s6wc1result,struct_dest);
    movefile(s6wc2result,struct_dest);
    movefile(s6wc3result,struct_dest);
    movefile(s6wmresult,struct_dest);
    
    % results of smoothed bias corrected normalized segmented of T1
    s10mwc1result = ls('s10mwc1*.nii');
    s10mwc2result = ls('s10mwc2*.nii');
    s10mwc3result = ls('s10mwc3*.nii');
    
    movefile(s10mwc1result,struct_dest);
    movefile(s10mwc2result,struct_dest);
    movefile(s10mwc3result,struct_dest);
    
    
    % -----------------------
    % 5 - from T2 directory
    % -----------------------
    cd(t2dir);
    
     % results of normalized of T2
    wresult = ls('w*.nii');
    movefile(wresult,struct_dest);
    
     % results of smoothed normalized of T2
    s6wresult = ls('s6w*.nii');
    movefile(s6wresult,struct_dest);
    
    % -----------------------
    % 6 - from T2* directory
    % -----------------------
    cd(t2stardir);
    
     % results of normalized of T2 *
    wresult = ls('w*.nii');
    movefile(wresult,struct_dest);
    
     % results of smoothed normalized of T2 *
    s6wresult = ls('s6w*.nii');
    movefile(s6wresult,struct_dest);
    
    
    
    
    
catch exception
    warning(getReport(exception));
    diary off;
    error('MATLAB:rstp_post_batch','Can''t move results to destination directories...')
    
end

rstp_result = 0;
diary off;
return 
end

