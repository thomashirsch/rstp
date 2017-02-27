#!/bin/bash

# env var for dev machine
MCRROOT=/homes_unix/hirsch/essai_spm_stand_alone/mcr/v90
MCRROOTBIS=/homes_unix/hirsch/essai_spm_stand_alone/mcr2016/v91
SPMSAROOT=/homes_unix/hirsch/essai_spm_stand_alone/spm12
CODEROOT=/homes_unix/hirsch/_new_pipe/docker_rstp
DATAROOT=/homes_unix/hirsch/_new_pipe/dataroot

# env var for docker machines, for VIP
#MCRROOT=/opt/mcrbis/v90
#MCRROOTBIS=/opt/mcr/v91
#SPMSAROOT=/opt/spm/spm12
#CODEROOT=/rstp_code
#DATAROOT=/rstp_data

info "Start running RSTP wrapper"

function die {
    local D=`date`
    echo "[ $D ] ERROR: $*"
    exit 1
}

function info {
    loc=`date`
    echo "[ $D ] INFO: $*"
}

if [ $# != 2 ]
then
    die "usage: $0 <input_tgz>  <output_dir>"
fi

INPUTFILE=$1
OUTPUTDIR=$2
info "parameters are ${INPUTFILE} and ${OUTPUTDIR} "
# it is lacking the path of the tar command

info "PATH is ${PATH}"
info "INPUTFILE is ${INPUTFILE}"

cd ${DATAROOT}

pwd

# untar of the inputfile 
TOP=`tar --exclude '*/*' --overwrite -tzf ${INPUTFILE}` || die "Cannot get top level directory from ${INPUTFILE}!"
info "TOP is ${TOP}"
tar zxf ${INPUTFILE} || die "Cannot untargz ${INPUTFILE}!"

info "TOP is ${TOP}"
export TOP

# List top directory in subject directory. There must be only 1. 
NSECONDTOP=`ls ${DATAROOT}/${TOP} | wc -l| awk '{print $1}'` || die "Cannot count directories in ${DATAROOT}/${TOP}!"
if [ ${NSECONDTOP} -ne 1 ] 
then
    die "Found 0 or more than 1 directory in ${PWD}!"
fi

SECONDTOP=`ls ${DATAROOT}/${TOP} || die "Cannot find directory in ${DATAROOT}/${TOP}"`
info "SECONDTOP is ${SECONDTOP}"

TROISTOP=`ls ${DATAROOT}/${TOP}/${SECONDTOP} || die "Cannot find directory in ${DATAROOT}/${TOP}/${SECONDTOP}"`
info "TROISTOP is ${TROISTOP}"


# Export FLI base directory expected by the matlab script. 
export FLIBASEDIR=${DATAROOT}/${TOP}/${SECONDTOP}/${TROISTOP}
info "FLIBASEDIR is ${FLIBASEDIR}"

# Export ATLAS base directory expected by the matlab script. 
export ATLASBASEDIR=${DATAROOT}/${TOP}/${SECONDTOP}/${TROISTOP}/Atlases

info "ATLASBASEDIR is ${ATLASBASEDIR}"



# find the XML file
# Search for the XML file of the subject
NXMLFILES=`ls ${FLIBASEDIR}/*.xml | wc -l | awk '{print $1}'` || die "Cannot count xml files in ${FLIBASEDIR}!"
if [ ${NXMLFILES} -ne 1 ] 
then
    die "Found 0 or more than 1 xml file in ${FLIBASEDIR}!"
fi
XMLFILE=`ls ${FLIBASEDIR}/*.xml` || die "Cannot find xml file in ${FLIBASEDIR}!"
info "XMLFILE is ${XMLFILE}"

BOLDDIR=${FLIBASEDIR}/EPIBOLD
info "BOLDDIR is ${BOLDDIR}"

T1DIR=${FLIBASEDIR}/T1
info "T1DIR is ${T1DIR}"

T2DIR=${FLIBASEDIR}/T2
info "T2DIR is ${T2DIR}"

T2starDIR=${FLIBASEDIR}/T2star
info "T2starDIR is ${T2DIRstar}"

#cd /opt/spm12
#ls -l



# cmds for dev machine
# 1 - make the batch 2 run with spm12 in standalone
(cd ${CODEROOT};
pwd;
exec   ./run_rstp_make_batch.sh ${MCRROOT}  ${FLIBASEDIR}   ${ATLASBASEDIR};
info "1 eval has been sent") &&


# 2 - send the batch to spm
(cd ${SPMSAROOT};
pwd;
exec ./run_spm12.sh ${MCRROOTBIS} batch ${CODEROOT}/batch2run.m;
info "2 eval has been sent";)&& 

# 3 - get the results of the batch and make the results tarball
(cd ${DATAROOT};
 mkdir results;
 RESULTSDIR=${DATAROOT}/results;
 info "RESULTSDIR is ${RESULTSDIR}"
 cd ${CODEROOT};
 pwd;
 exec ./run_rstp_post_batch.sh ${MCRROOT}  ${BOLDDIR} ${T1DIR} ${T2DIR} ${T2starDIR}  ${RESULTSDIR};
 info "3 eval has been sent: we get the results";)&&

# 4 - create a tarball from the results then give it to VIP by the outputdir argument
( cd  ${OUTPUTDIR} 
  # and copy the logs file to the outputdir
  cp ${CODEROOT}/*.log .
tar -cvz   ${RESULTSDIR}
info "4 eval has been sent: we get the results in a tarball; we give the tarball to VIP";)

info "End running RSTP wrapper"