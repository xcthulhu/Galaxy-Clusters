#!/bin/sh -x

export IN=$1
export OUT=$2

BIN_DIR="$(dirname "${BASH_SOURCE[0]}")"
source ${BIN_DIR}/XMM_common.sh

evselect table="$IN:EVENTS" expression='#XMMEA_EP&&(PI>10000)&&(PATTERN==0)' rateset="$OUT" timebinsize=10 withrateset=yes maketimecolumn=yes makeratecolumn=yes
