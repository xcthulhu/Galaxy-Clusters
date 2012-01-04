#!/bin/sh

if [ -d /usr/local/heasoft-6.4.1/x86_64-unknown-linux-gnu-libc2.5/ ] ; then
	export HEADAS="/usr/local/heasoft-6.4.1/x86_64-unknown-linux-gnu-libc2.5/"
elif [ -d /usr/share/heasoft/heasoft-6.10/i386-apple-darwin9.8.0 ] ; then
	export HEADAS="/usr/share/heasoft/heasoft-6.10/i386-apple-darwin9.8.0/"
fi

if [ -d /usr/local/XMM/xmmsas_20110223_1801/ ] ; then
	export SAS_DIR="/usr/local/XMM/xmmsas_20110223_1801/"
elif [ -d /usr/local/XMM/xmmsas_20110223_1803/ ] ; then
	export SAS_DIR="/usr/local/XMM/xmmsas_20110223_1803/"
fi

if [ -d /usr/local/XMM/CCF ] ; then
	export SAS_CCFPATH=/usr/local/XMM/CCF
else
	echo NO CCF > /dev/stderr
	echo I AM GOING TO DIE NOW > /dev/stderr
	exit 1
fi

source $HEADAS/headas-init.sh
source $SAS_DIR/setsas.sh

odfingest odfdir=$SAS_ODF outdir=$SAS_ODF
