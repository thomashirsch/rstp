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
    
    % 1- getresults from step 1
    cd(bolddir);
    
    result1 = ls('rp*.txt');
    movefile(result1,BOLD_dest);
    
    % 2- getresults from step 2
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
    
    % 5 - from T1
    cd(t1dir);
    cd(t2dir);
    cd(t2stardir);
    cd(t1dir);
    
catch exception
    warning(getReport(exception));
    error('MATLAB:rstp_post_batch','Can''t move results to destination directories...')
    diary off;
end
rstp_result = 0;
diary off;
return 
end

