#!/bin/sh -x

for i in `find $1 -iname "*.tsv"` ; do 
	if [ "`grep -i 'CLUSTERS OF GALAXIES' $i`" ] ; then 
		echo `wc -l $i` `head -2 $i | cut -f 8` >> $1/$$.txt
	fi 
done

sort -nr $1/$$.txt > $1/galaxy_clusters.txt
rm $1/$$.txt
