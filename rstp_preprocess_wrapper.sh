#!/bin/bash

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
    die "usage: $0 <input_tgz> <output_dir>"
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
TOP=`tar --exclude '*/*' -tzf ${INPUTFILE}` || die "Cannot get top level directory from ${INPUTFILE}!"
info "TOP is ${TOP}"
tar zxf ${INPUTFILE} || die "Cannot untargz ${INPUTFILE}!"

info "TOP is ${TOP}"

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

# find the XML file
# Search for the XML file of the subject
NXMLFILES=`ls ${FLIBASEDIR}/*.xml | wc -l | awk '{print $1}'` || die "Cannot count xml files in ${FLIBASEDIR}!"
if [ ${NXMLFILES} -ne 1 ] 
then
    die "Found 0 or more than 1 xml file in ${FLIBASEDIR}!"
fi
XMLFILE=`ls ${FLIBASEDIR}/*.xml` || die "Cannot find xml file in ${FLIBASEDIR}!"

info "XMLFILE is ${XMLFILE}"





info "End running RSTP wrapper"