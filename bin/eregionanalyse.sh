#!/bin/sh

export IN=$1
export RA_VAL=$2
export DEC_VAL=$3
export R=$4
export R1=$5
export R2=$6

BIN_DIR="$(dirname "${BASH_SOURCE[0]}")"
source $BIN_DIR/XMM_common.sh &> /dev/null

eregionanalyse imageset=${IN} \
		srcexp="((RA,DEC) in circle(${RA_VAL},${DEC_VAL},${R}))" \
		backexp="((RA,DEC) in annulus(${RA_VAL},${DEC_VAL},${R1},${R2}))" \
		-V 4 | grep "encircled energy factor" | cut -d' ' -f5
