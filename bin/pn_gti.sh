#!/bin/sh -x

export IN=$1
export OUT=$2
source $BIN/XMM_common.sh
source $HEADAS/headas-init.sh
source $SAS_DIR/setsas.sh

tabgtigen table=$IN expression="RATE<1.0" gtiset=$OUT
