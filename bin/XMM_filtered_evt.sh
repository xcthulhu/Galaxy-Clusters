#!/bin/sh -x

export IN=$1
export GTI=$2
export OUT=$3

BIN_DIR="$(dirname "${BASH_SOURCE[0]}")"
source ${BIN_DIR}/XMM_common.sh

evselect table="${IN}:EVENTS" withfilteredset=yes expression="GTI(${GTI},TIME)" filteredset=${OUT} filtertype=expression keepfilteroutput=yes updateexposure=yes filterexposure=yes
