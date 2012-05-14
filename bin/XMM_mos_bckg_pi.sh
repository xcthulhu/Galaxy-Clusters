#!/bin/sh -x

export IN=$1 # better be a filtered background EVT file
export OUT=$2

BIN_DIR="$(dirname "${BASH_SOURCE[0]}")"
source ${BIN_DIR}/XMM_common.sh

evselect table="${IN}:EVENTS" energycolumn='PI' withfilteredset=yes keepfilteroutput=no \
         filtertype='expression' expression='FLAG==0' \
         withspectrumset=yes spectrumset="${OUT}" spectralbinsize=15 withspecranges=yes specchannelmin=0 specchannelmax=11999
