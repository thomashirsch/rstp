function [ rstp_result ] = rstp_post_batch(bolddir, ouputdir )
% move the batch results to outputdir 
% to prepare the results tarball

% Move the processed files into destdir for tarball archiving
BOLD_dest   = fullfile(ouputdir,'processed_fMRI');
struct_dest = fullfile(ouputdir,'processed_structural');

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
    for col = 1:ncols
          movefile(result2{col},BOLD_dest);
    end
    
catch exception
    warning(getReport(exception));
    error('MATLAB:rstp_post_batch','Can''t move results to destination directories...')
    
end
rstp_result = 0;
return 
end

