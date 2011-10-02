#!/bin/sh -x

for i in `find $1 -iname "nedshifts.tsv"` ; do 
	if [ "`grep -i 'GClstr' $i`" ] ; then 
		IDIRNAME=`dirname $i` 
		OBS="${IDIRNAME}/${IDIRNAME}.tsv"
		NED=`grep GClstr $i | cut -f1,6`
		echo `wc -l ${OBS}` "	" `head -2 ${OBS} | cut -f 8` "	" $NED >> $1/$$.txt
	fi 
done

sort -nr $1/$$.txt > $1/ned_galaxy_clusters.txt
rm $1/$$.txt
