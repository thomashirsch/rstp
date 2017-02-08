function [ matlabbatch ] = spm12_step1(xml_info)
% This function enables setting some parameters for the SPM12 preprocessing
% batch and running the SPM job.
%   xmlxml_info = path to XML file specifying the role of each file, and some
%   context-dependent xml_information, as produced by datagrabber
%   template = the .mat file of the matlabbatch job
% The XML file should contain paths to:
% structural: the 'nice' T1 image of the subject
%             A T2-W image if it exists
%             A T2*-W image if its exists
% functional: the EPI BOLD time series, along with TR and slice-timing xml_info
%
% FLIBASEDIR and FLIATLASDIR environement variables should be set. 
%
% The output will be written in SPM12_preprocessing/<participant>/<session>
% (participant and session taken from the xml_info). An XML file catalog is
% written at that location.
%
%  TH janvier 2017 - GIN UMR5296

%% Utilities

    function flist = fix_filenames(scan,dynamics)
        % From XML filename text dump to cell array of files with time-index specified
        fnames = regexp(scan.file.Text,'\n','split');
        nfiles = length(fnames);
        if dynamics==nfiles
            
            flist=cell(nfiles,1);
            for i=1:nfiles
                flist{i}=[cell2mat(fnames(i)),',1'];
            end
        elseif nfiles==1
            for i=1:dynamics
                flist=cell(dynamics,1);
                flist{i}=[cell2mat(fnames(1)),',',num2str(i)];
            end
        else
            error('MATLAB:spmpreproc_datagrabber','Wrong number of dynamics.')
        end
        return
    end


%% Setting things up

% todo resoudre apres
% Get environment variabmes from shell OU la récupérer en variable donnée
% par le bash ?
% [status, basedir] = system('echo $FLIBASEDIR');  
% basedir=basedir(1:end-1); % plain weird
% if status~=0
%     error('MATLAB:spm12_step1','FLIBASEDIR not set. Aborting.')
% end
basedir='/homes_unix/hirsch/_new_pipe/new_data/data_set/t0009/repos01';
atlasdir='/homes_unix/hirsch/_new_pipe/new_data/data_set/Atlases';


diary(fullfile('spm12_step1.log'));
echo on;

wd=pwd;

% first we analyse the XML file defining the dataset
try
    xml_parent=xml_info;
    xml_info=xml2struct(xml_info);
catch exception
    warning(getReport(exception));
    error('MATLAB:SPM12_step1','Can''t find or parse XML mrdata_descriptor file...');
end

name_subject = xml_info.RS_analysis.mrData.subject_information.name_subject.Text;
name_session = xml_info.RS_analysis.mrData.subject_information.name_session.Text;

% then we go to the base directory where is the data
try
    cd(basedir);
catch exception
    warning(getReport(exception));
    error('MATLAB:spmpreproc_wrapper','Can''t cd to $BASEDIR...')
end

% Prepare the filenames of all data

BOLD_dir = fullfile(basedir,xml_info.RS_analysis.mrData.functional.EPIBOLD.file.Text)
nb_pts = str2double(xml_info.RS_analysis.mrData.functional.EPIBOLD.parameters.dynamics.value.Text)

all_fn = dir(BOLD_dir);

flist=cell(nb_pts,1);
for i=1:nb_pts
    %name = fullfile(dir_data, all_fn(i+2).name)
    %flist{i}=[str2mat(all_fn(i+2).name),',1'];
    flist{i} = fullfile(BOLD_dir, all_fn(i+2).name);
end

BOLD=flist

T1=fullfile(basedir, xml_info.RS_analysis.mrData.structural.T1.file.Text)
T2=fullfile(basedir, xml_info.RS_analysis.mrData.structural.T2.file.Text)
T2star=fullfile(basedir, xml_info.RS_analysis.mrData.structural.T2star.file.Text)

% --------------------------------
% STEP 1 - here starts the job batch management step 1 realign
%------------------------------------------

% we initialyse the spm batch man
try
    spm_jobman('initcfg');
catch exception
    warning(getReport(exception));
    error('MATLAB:SPM12_step1','Can''t initialize spm job manager.')
end

% template for step1 realign
matlabbatch{1}.spm.spatial.realign.estimate.data = {'<UNDEFINED>'};
matlabbatch{1}.spm.spatial.realign.estimate.eoptions.quality = 0.9;
matlabbatch{1}.spm.spatial.realign.estimate.eoptions.sep = 4;
matlabbatch{1}.spm.spatial.realign.estimate.eoptions.fwhm = 5;
matlabbatch{1}.spm.spatial.realign.estimate.eoptions.rtm = 0;
matlabbatch{1}.spm.spatial.realign.estimate.eoptions.interp = 2;
matlabbatch{1}.spm.spatial.realign.estimate.eoptions.wrap = [0 0 0];
matlabbatch{1}.spm.spatial.realign.estimate.eoptions.weight = '';
% end of template for step1 realign

% the dynamic data comes here
try
    matlabbatch{1}.spm.spatial.realign.estimate.data = {BOLD}';
catch exception
    warning(getReport(exception));
    error('MATLAB:SPM12_step1','Failed to set job parameters; The supplied XML may not fit the supplied template and/or this wrapper script.')
end

% end step 1
%------------------------------------------

% --------------------------------
% STEP 2 - here starts the job batch management step 2 temporal reslicing
%------------------------------------------

% the template
matlabbatch{2}.spm.temporal.st.scans{1}(1) = cfg_dep('Realign: Estimate: Realigned Images (Sess 1)', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','sess', '()',{1}, '.','cfiles'));
matlabbatch{2}.spm.temporal.st.nslices = 31;
matlabbatch{2}.spm.temporal.st.tr = 2;
matlabbatch{2}.spm.temporal.st.ta = 1.93548387096774;
matlabbatch{2}.spm.temporal.st.so = [1 3 5 7 9 11 13 15 17 19 21 23 25 27 29 31 2 4 6 8 10 12 14 16 18 20 22 24 26 28 30];
matlabbatch{2}.spm.temporal.st.refslice = 31;
matlabbatch{2}.spm.temporal.st.prefix = 'a';

% the the dynamics
try
    matlabbatch{2}.spm.temporal.st.nslices = str2double(xml_info.RS_analysis.mrData.functional.EPIBOLD.parameters.nb_slices.value.Text);
    matlabbatch{2}.spm.temporal.st.tr = str2double(xml_info.RS_analysis.mrData.functional.EPIBOLD.parameters.TR.value.Text);
    matlabbatch{2}.spm.temporal.st.ta = matlabbatch{2}.spm.temporal.st.tr - matlabbatch{2}.spm.temporal.st.tr/matlabbatch{2}.spm.temporal.st.nslices;
    matlabbatch{2}.spm.temporal.st.so = str2num(xml_info.RS_analysis.mrData.functional.EPIBOLD.parameters.sliceTimingVector.value.Text); %#ok<ST2NM>
    matlabbatch{2}.spm.temporal.st.refslice = matlabbatch{2}.spm.temporal.st.so(ceil(matlabbatch{2}.spm.temporal.st.nslices/2));
catch exception
    warning(getReport(exception));
    error('MATLAB:SPM12_step2','Failed to set job parameters; The supplied XML may not fit the supplied template and/or this wrapper script.')
end 


% --------------------------------
% STEP 3 - here starts the job batch management step 3 coregistration  bold
% T2*
% 
%------------------------------------------

% the template
matlabbatch{3}.spm.spatial.coreg.estimate.ref = '<UNDEFINED>';
matlabbatch{3}.spm.spatial.coreg.estimate.source = '<UNDEFINED>';
matlabbatch{3}.spm.spatial.coreg.estimate.other(1) = cfg_dep('Slice Timing: Slice Timing Corr. Images (Sess 1)', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{1}, '.','files'));
matlabbatch{3}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'ncc';
matlabbatch{3}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
matlabbatch{3}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
matlabbatch{3}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];
% the the dynamics
try
    matlabbatch{3}.spm.spatial.coreg.estimate.ref = cellstr(T2star);
    matlabbatch{3}.spm.spatial.coreg.estimate.source = cellstr(matlabbatch{1}.spm.spatial.realign.estimate.data{1}{1});
catch exception
    warning(getReport(exception));
    error('MATLAB:SPM12_step3','Failed to set job parameters; The supplied XML may not fit the supplied template and/or this wrapper script.')
end        


% --------------------------------
% STEP 4 - here starts the job batch management step 4 coregistration  T2
% T2*
% 
%------------------------------------------

% the template
matlabbatch{4}.spm.spatial.coreg.estimate.ref = '<UNDEFINED>';
matlabbatch{4}.spm.spatial.coreg.estimate.source = '<UNDEFINED>';
matlabbatch{4}.spm.spatial.coreg.estimate.other(1) = cfg_dep('Coregister: Estimate: Coregistered Images', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','cfiles'));
matlabbatch{4}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
matlabbatch{4}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
matlabbatch{4}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
matlabbatch{4}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];
% the dynamics 
try
    matlabbatch{4}.spm.spatial.coreg.estimate.ref = cellstr(T2);
    matlabbatch{4}.spm.spatial.coreg.estimate.source = cellstr(T2star);
catch exception
    warning(getReport(exception));
    error('MATLAB:SPM12_step4','Failed to set job parameters; The supplied XML may not fit the supplied template and/or this wrapper script.')
end 
    

% --------------------------------
% STEP 5 - here starts the job batch management step 5 coregistration  T1
% T2
% 
%------------------------------------------
% the template
matlabbatch{5}.spm.spatial.coreg.estimate.ref = '<UNDEFINED>';
matlabbatch{5}.spm.spatial.coreg.estimate.source = '<UNDEFINED>';
matlabbatch{5}.spm.spatial.coreg.estimate.other(1) = cfg_dep('Coregister: Estimate: Coregistered Images', substruct('.','val', '{}',{4}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','cfiles'));
matlabbatch{5}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
matlabbatch{5}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
matlabbatch{5}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
matlabbatch{5}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];
% the dynamics 
try
    matlabbatch{5}.spm.spatial.coreg.estimate.ref = cellstr(T1);
    matlabbatch{5}.spm.spatial.coreg.estimate.source = cellstr(T2);
catch exception
    warning(getReport(exception));
    error('MATLAB:SPM12_step5','Failed to set job parameters; The supplied XML may not fit the supplied template and/or this wrapper script.')
end 

% --------------------------------
% STEP 6 - here starts the job batch management step 6 segmentation with
% the atlas
% 
%------------------------------------------

% first we get the atlas - no as it will be in a fixed path relatively to
% datarootdir


% the template and the dynamics
try
    matlabbatch{6}.spm.spatial.preproc.channel.vols = cellstr(T1);
    matlabbatch{6}.spm.spatial.preproc.tissue(1).tpm = {[fullfile(atlasdir,'TPM.nii'),',1']};
    matlabbatch{6}.spm.spatial.preproc.tissue(2).tpm = {[fullfile(atlasdir,'TPM.nii'),',2']};
    matlabbatch{6}.spm.spatial.preproc.tissue(3).tpm = {[fullfile(atlasdir,'TPM.nii'),',3']};
    matlabbatch{6}.spm.spatial.preproc.tissue(4).tpm = {[fullfile(atlasdir,'TPM.nii'),',4']};
    matlabbatch{6}.spm.spatial.preproc.tissue(5).tpm = {[fullfile(atlasdir,'TPM.nii'),',5']};
    matlabbatch{6}.spm.spatial.preproc.tissue(6).tpm = {[fullfile(atlasdir,'TPM.nii'),',6']};
catch exception
    warning(getReport(exception));
    error('MATLAB:SPM12_step6','Failed to set job parameters; The supplied XML may not fit the supplied template and/or this wrapper script.')
end 

% --------------------------------
% STEP 7 - here starts the job batch management step 7 normalisation
% 
%------------------------------------------
try
    matlabbatch{7}.spm.spatial.normalise.write.subj.def(1) = cfg_dep('Segment: Forward Deformations', substruct('.','val', '{}',{6}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','fordef', '()',{':'}));
    matlabbatch{7}.spm.spatial.normalise.write.subj.resample(1) = cfg_dep('Coregister: Estimate: Coregistered Images', substruct('.','val', '{}',{5}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','cfiles'));
    matlabbatch{7}.spm.spatial.normalise.write.subj.resample(2) = cfg_dep('Segment: Bias Corrected (1)', substruct('.','val', '{}',{6}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','channel', '()',{1}, '.','biascorr', '()',{':'}));
    matlabbatch{7}.spm.spatial.normalise.write.subj.resample(3) = cfg_dep('Segment: c1 Images', substruct('.','val', '{}',{6}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','tiss', '()',{1}, '.','c', '()',{':'}));
    matlabbatch{7}.spm.spatial.normalise.write.subj.resample(4) = cfg_dep('Segment: c2 Images', substruct('.','val', '{}',{6}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','tiss', '()',{2}, '.','c', '()',{':'}));
    matlabbatch{7}.spm.spatial.normalise.write.subj.resample(5) = cfg_dep('Segment: c3 Images', substruct('.','val', '{}',{6}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','tiss', '()',{3}, '.','c', '()',{':'}));
    matlabbatch{7}.spm.spatial.normalise.write.woptions.bb = [-90 -126 -72
                                                          90 90 108];
    matlabbatch{7}.spm.spatial.normalise.write.woptions.vox = [2 2 2];
    matlabbatch{7}.spm.spatial.normalise.write.woptions.interp = 3;
catch exception
    warning(getReport(exception));
    error('MATLAB:SPM12_step7','Failed to set job parameters; The supplied XML may not fit the supplied template and/or this wrapper script.')
end 
    
%------------------------------------------
%------------------------------------------
% the complete batch launch
%------------------------------------------

try    spm_jobman('run',matlabbatch);
catch exception
    warning('MATLAB:SPM12_step1','SPM matlabbatch job step1 failed to run.');
    % je ne vois pas pourquoi cd(wd)
    
    diary off
    rethrow(exception)
end

%------------------------------------------
% ----------------------
% memorize the results todo apres

% cd('../../../data_results')
% pwd
% results_dir=fullfile('spm_preproc_step1');
% 
% if
% ~isdir(results_dir)
%     try
%         mkdir(results_dir);
%     catch exception
% 	    warning(getReport(exception));
%         error('MATLAB:spmpreproc_wrapper',['Can''t create directory ',results_dir,'. Check access rights...'])
%     end
% else
%     warning('MATLAB:spmpreproc_wrapper','Destination folder already exists, overwriting.')
% end
% 
% % then move the result files to results_dir
% movefile(fullfile(fileparts(char(BOLD(1))),[matlabbatch{1}.spm.spatial.realign.estimate.prefix,'a*']),results_dir);

echo off
% spm('fmri');
return
end
