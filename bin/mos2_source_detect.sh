#!/bin/sh -x

export EMLLIST=$1
export EVENTSETS=$2
export ATTITUDESET=$3
export IMAGESETS=${@:4}

BIN_DIR="$(dirname "${BASH_SOURCE[0]}")"
source ${BIN_DIR}/XMM_common.sh

edetect_chain imagesets="${IMAGESETS}" eventsets=${EVENTSETS} attitudeset=${ATTITUDESET} pimin='200 500 1000 2000 4500' pimax='500 1000 2000 4500 12000' ecf='0.994 1.620 0.706 0.273 0.030' eboxm_list="M_${EMLLIST}" eboxl_list="L_${EMLLIST}" eml_list="${EMLLIST}" esen_mlmin=15 esp_nsplinenodes=16
