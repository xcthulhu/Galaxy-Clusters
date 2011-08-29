#!/bin/sh -x

for i in `ls -d --dereference-command-line-symlink-to-dir $1/*` ; do
	if [ -d $i ] ; then 
		if [ -e $i/primary/acis*evt2*.gz ] ; then
			gunzip $i/primary/acis*evt2*.gz
		fi

		if [ -e $i/primary/acis*evt2.fits ] ; then
			SRC=`basename $i/primary/acis*evt2.fits | sed 's/evt2.fits$/srcs/'`
			SOURCES="`basename $i`/primary/$SRC $SOURCES"
			echo "SOURCES=$SRC" > $i/primary/Makefile
			echo "include ../../../chandra_process.mk" >> $i/primary/Makefile
		else
			echo "No evt2 file in $i"
			break
		fi
	fi
done

echo -e "SOURCES=$SOURCES\n" > $1/Makefile
echo -e "all: \$(SOURCES)\n" >> $1/Makefile

for i in $SOURCES; do
	echo -e "$i:" >> $1/Makefile
	echo -e "	\$(MAKE) -C `dirname $i`\n" >> $1/Makefile
done
