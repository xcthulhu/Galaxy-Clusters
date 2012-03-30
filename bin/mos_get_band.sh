#!/bin/sh -x

export IN=$1
export GTI=$2
export OUT=$3
export LOW=$4
export HIGH=$5

BIN_DIR="$(dirname "${BASH_SOURCE[0]}")"
source ${BIN_DIR}/XMM_common.sh

evselect table=$IN:EVENTS imagebinning='binSize' \
  imageset="$OUT" withimageset=yes xcolumn='X' ycolumn='Y' \
  ximagebinsize=80 yimagebinsize=80 \
  expression="#XMMEA_EM&&(PI in [$LOW:$HIGH])&&(PATTERN in [0:12])&& gti($GTI,TIME)"
