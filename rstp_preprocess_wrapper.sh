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

cd /rstp_data

pwd

# untar of the inputfile 
TOP=`tar --exclude '*/*' -tzf ${INPUTFILE}` || die "Cannot get top level directory from ${INPUTFILE}!"
info "TOP is ${TOP}"
tar zxf ${INPUTFILE} || die "Cannot untargz ${INPUTFILE}!"

ls -l /rstp_data/dataset





info "End running RSTP wrapper"