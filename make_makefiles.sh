#!/bin/sh

rm -f $1/Makefile

for i in `find $1 -type d -depth 1 -print` ; do
	echo "BASEDIR=../.." > $i/Makefile
	echo 'include $(BASEDIR)/analyze.mk' >> $i/Makefile
	echo "`basename $i` : " >> $1/Makefile
	echo "	make -C $i" >> $1/Makefile
done
