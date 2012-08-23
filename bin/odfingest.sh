#!/bin/sh

source $BIN/XMM_common.sh

# Make sure to set SAS_ODF
odfingest -V 5 odfdir=$SAS_ODF outdir=$SAS_ODF
