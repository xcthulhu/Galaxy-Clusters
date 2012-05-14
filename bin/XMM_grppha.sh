#!/bin/sh -x

export FORGROUND_PI=$1 
export BACKFILE=$2
export RESPFILE=$3
export OUT=$4

BIN_DIR="$(dirname "${BASH_SOURCE[0]}")"
source ${BIN_DIR}/XMM_common.sh

rm -f ${OUT}
grppha ${FORGROUND_PI} ${OUT} "chkey BACKFILE ${BACKFILE} & chkey RESPFILE ${RESPFILE} & group min 25 & exit" 
