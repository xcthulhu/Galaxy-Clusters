#!/bin/sh -x

export EVT_FILE=$1
export RA=$2
export DEC=$3
export R=$4
export OUT_PI_FILE=$5

BIN_DIR="$(dirname "${BASH_SOURCE[0]}")"
source ${BIN_DIR}/XMM_common.sh

evselect table=${EVT_FILE}:EVENTS energycolumn='PI' withfilteredset=yes keepfilteroutput=no \
         filtertype='expression' expression="((RA,DEC) in CIRCLE(${RA},${DEC},${R}))&&(FLAG==0)" \
         withspectrumset=yes spectrumset=${OUT_PI_FILE} spectralbinsize=5 \
         withspecranges=yes specchannelmin=0 specchannelmax=20479
