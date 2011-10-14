#!/bin/sh -x

for i in `find $1 -iname "*.tsv"` ; do 
	if [ "`grep -i 'CLUSTERS OF GALAXIES' $i`" ] ; then 
		IDIRNAME=`dirname $i` 
		make -C $IDIRNAME nedshifts.tsv 
		NED=`grep GClstr $IDIRNAME/nedshifts.tsv | cut -f1,6`
		echo `wc -l $i` "	" `head -2 $i | cut -f 8` "	" $NED
	fi 
done
