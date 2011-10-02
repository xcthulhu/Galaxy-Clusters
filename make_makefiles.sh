#!/bin/sh -x

rm -f $1/Makefile

for i in `find $1 -maxdepth 1 -mindepth 1 -type d -print` ; do
	echo "BASEDIR=../.." > $i/Makefile
	echo 'include $(BASEDIR)/analyze.mk' >> $i/Makefile
	echo "`basename $i` : " >> $1/Makefile
	echo -e "	make -C $i\n" >> $1/Makefile
	ln -s ../../chandra_process.mk $i
	ln -s ../../get_XMM_obs_url.py $i
	ln -s ../../chandra_manhandler.py $i
	ln -s ../../get_XMM_obs.sh $i
done
