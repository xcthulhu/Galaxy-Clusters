#!/bin/sh -x

export IN=$1
export OUT=$2

BIN_DIR="$(dirname "${BASH_SOURCE[0]}")"
source $BIN_DIR/XMM_common.sh

#tabgtigen table=$IN expression="RATE<0.35" gtiset=$OUT
tabgtigen table="$IN:RATE" expression="RATE<0.35" timecolumn="TIME" gtiset=$OUT
