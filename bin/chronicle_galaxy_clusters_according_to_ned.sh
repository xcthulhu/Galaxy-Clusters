#!/bin/sh -x

echo $1 $2
# Make sure you have created all of the necessary nedshifts.tsv files before running
for i in `find $2 -iname "nedshifts.tsv"` ; do 
	NED=`grep GClstr $i | cut -f1,6 | tr "\n" "\t"`
	if [ -n "${NED}" ] ; then 
		IDIRNAME=`ruby -e "require 'pathname' ; puts Pathname.new(\"$i\").dirname.cleanpath"`
		OBS="${IDIRNAME}/${IDIRNAME}.tsv"
		IDCOUNT=`wc -l ${OBS} | cut -f1 -d" "`
		if [ ${IDCOUNT} -ge $1 ] ; then
			echo ${IDCOUNT} "	" $OBS "	" `head -2 ${OBS} | cut -f 8` "	" $NED
		fi
	fi 
done
