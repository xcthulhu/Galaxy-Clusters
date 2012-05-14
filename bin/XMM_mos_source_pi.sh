#!/bin/sh -x

export IN=$1 # better be a filtered EVT file
export X=$2
export Y=$3
export R=$4
export OUT=$5

BIN_DIR="$(dirname "${BASH_SOURCE[0]}")"
source ${BIN_DIR}/XMM_common.sh

evselect table="${IN}:EVENTS" energycolumn='PI' filtertype='expression' expression="((X,Y) in CIRCLE(${X},${Y},${R}))&&(FLAG==0)" withspectrumset=yes spectrumset="${OUT}" spectralbinsize=15 withspecranges=yes specchannelmin=0 specchannelmax=11999
