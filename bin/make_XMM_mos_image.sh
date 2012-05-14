#!/bin/sh -x

export MOS_EVT=$1 
export MOS_GTI=$2
export MOS_IMG=$3

source $BIN/XMM_common.sh

evselect table=${MOS_EVT}:'EVENTS' imagebinning='binSize' \
  imageset=${MOS_IMG} withimageset=yes xcolumn='X' ycolumn='Y' \
    ximagebinsize=80 yimagebinsize=80 \
      expression="#XMMEA_EM && (PI in [200:10000]) && (PATTERN in [0:12]) && gti(${MOS_GTI},TIME)"
