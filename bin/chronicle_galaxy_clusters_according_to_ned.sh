#!/bin/sh -x

# Make sure you have created all of the necessary nedshifts.tsv files before running
for i in `find $4 -iname "nedshifts.tsv"` ; do 
	NED=`grep GClstr $i | cut -f1,6 | awk -F"\t" "$1 <= \\\$2 && \\\$2 <= $2 {print \\\$0}" | tr "\t\n" ",;"`
	if [ -n "${NED}" ] ; then 
		IDIRNAME=`ruby -e "require 'pathname' ; puts Pathname.new(\"$i\").dirname.cleanpath"`
		OBS="${IDIRNAME}/${IDIRNAME}.tsv"
		IDCOUNT=`wc -l ${OBS} | cut -f1 -d" "`
		if [ ${IDCOUNT} -ge $3 ] ; then
			echo ${IDCOUNT} "	" $OBS "	" `head -2 ${OBS} | cut -f 8` "	" $NED
		fi
	fi 
done
