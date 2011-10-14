#!/bin/sh -x

for i in `ls -d --dereference-command-line-symlink-to-dir $1/*` ; do
	if [ -d $i ] ; then 
		if [ -e $i/primary/acis*evt2*.gz ] ; then
			gunzip $i/primary/acis*evt2*.gz
		fi

		if [ -e $i/primary/acis*evt2.fits ] ; then
			SRC=`basename $i/primary/acis*evt2.fits | sed 's/evt2.fits$/srcs.reg/'`
			SOURCES="`basename $i`/primary/$SRC $SOURCES"
			echo "SOURCES=$SRC" > $i/primary/Makefile
			echo "include ../../../chandra_process.mk" >> $i/primary/Makefile
		else
			echo "No evt2 file in $i"
			break
		fi
	fi
done

echo "SOURCES=$SOURCES" > $1/Makefile
echo >> $1/Makefile
echo "all: \$(SOURCES)" >> $1/Makefile
echo >> $1/Makefile

for i in $SOURCES; do
	echo "$i:" >> $1/Makefile
	echo "	\$(MAKE) -C `dirname $i`" >> $1/Makefile
done
