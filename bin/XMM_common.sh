#!/bin/sh


function expand() {
	ruby -e "puts File.expand_path(\"$1\")"
}

BIN_DIR="$(dirname "${BASH_SOURCE[0]}")"
if ([ ! ${BIN} ] || [ ! -d ${BIN} ]) && [ -d ${BIN_DIR} ] ; then 
	export BIN=`expand ${BIN_DIR}`
fi

if [[ ! "${PATH}" =~ "${BIN}" ]] ; then
	export PATH=${BIN}:${PATH}
fi

export DATRED=`expand .` 

if ([ ! ${SAS_ODF} ] || [ ! -d ${SAS_ODF} ]) && [ -d ../odf ] ; then
	export SAS_ODF=`expand ../odf`
fi

if ([ ! ${SAS_CCF} ] || [ ! -d ${SAS_CCF} ]) ; then 
	if [ -e ccf.cif ] ; then
		export SAS_CCF=`expand ccf.cif`
	elif [ -e ../work/ccf.cif ] ; then 
		export SAS_CCF=`expand ../work/ccf.cif`
	fi
fi

# Add support for more platforms as necessary
if [ -d ${BIN}/../heasoft/x86_64-unknown-linux-gnu-libc2.5 ] ; then
	export HEADAS=`expand ${BIN}/../heasoft/x86_64-unknown-linux-gnu-libc2.5`
elif [ -d ${BIN}/../heasoft/i386-apple-darwin10.8.0 ] ; then
	export HEADAS=`expand ${BIN}/../heasoft/i386-apple-darwin10.8.0`
fi

if [ -d ${BIN}/../sas/xmmsas/ ] ; then
        export SAS_DIR=`expand ${BIN}/../sas/xmmsas/`
fi

if [ -d ${BIN}/../sas/CCF ] ; then
        export SAS_CCFPATH=`expand ${BIN}/../sas/CCF`
else
        echo NO CCF > /dev/stderr
        echo I AM GOING TO DIE NOW > /dev/stderr
        exit 1
fi

source $HEADAS/headas-init.sh
source $SAS_DIR/setsas.sh
