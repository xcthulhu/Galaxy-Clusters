#!/bin/sh -x

# Make sure you have created all of the necessary nedshifts.tsv files before running
for i in `find $1 -iname "nedshifts.tsv"` ; do 
	if [ "`grep -i 'GClstr' $i`" ] ; then 
		IDIRNAME=`dirname $i` 
		OBS="${IDIRNAME}/${IDIRNAME}.tsv"
		NED=`grep GClstr $i | cut -f1,6`
		echo `wc -l ${OBS}` "	" `head -2 ${OBS} | cut -f 8` "	" $NED
	fi 
done
