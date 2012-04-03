#!/bin/sh -x

export IN=$1
export OUT=$2

BIN_DIR="$(dirname "${BASH_SOURCE[0]}")"
source ${BIN_DIR}/XMM_common.sh

evselect table=$IN xcolumn=X ycolumn=Y imagebinning=binSize \
         ximagebinsize=20 yimagebinsize=20 \
         withimageset=true imageset=$OUT
