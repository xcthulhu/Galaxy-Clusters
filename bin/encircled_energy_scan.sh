#!/bin/sh -x

export EVT_FILE=$1
export RA=$2
export DEC=$3
export STEP_SIZE=$4
export R_LIMIT=$5
export RAW_R1=$6
export RAW_R2=$7
export R1=`echo "scale=20; 1 / 3600. * $6" | bc`
export R2=`echo "scale=20; 1 / 3600. * $7" | bc`
export OUT=$8

BIN_DIR="$(dirname "${BASH_SOURCE[0]}")"
source $BIN_DIR/XMM_common.sh &> /dev/null

encircled_energy(){
  eregionanalyse imageset=$1 \
		srcexp="((RA,DEC) in circle($2,$3,$4))" \
		backexp="((RA,DEC) in annulus($2,$3,$5,$6))" \
		-V 4 | grep "encircled energy factor" | cut -d' ' -f5
}

STEPS=$((${R_LIMIT} / ${STEP_SIZE}))
rm -f ${OUT}
for i in $(seq 0 ${STEPS}) ; do
	R=`echo "scale=20; 1 / 3600. * $i * ${STEP_SIZE}" | bc`
	echo ${RA}	${DEC}	${RAW_R1}	${RAW_R2}	$(($i * ${STEP_SIZE})) `encircled_energy $EVT_FILE $RA $DEC $R $R1 $R2` | tee -a ${OUT}
done
