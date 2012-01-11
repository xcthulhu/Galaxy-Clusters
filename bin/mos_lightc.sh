#!/bin/sh -x

export IN=$1
export OUT=$2
source $BIN/XMM_common.sh
source $HEADAS/headas-init.sh
source $SAS_DIR/setsas.sh

evselect table="$IN:EVENTS" expression='#XMMEA_EM&&(PI>10000)&&(PATTERN==0)' rateset="$OUT" timebinsize=10 withrateset=yes maketimecolumn=yes makeratecolumn=yes
