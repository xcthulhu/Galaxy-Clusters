#!/bin/sh -x

if [ -e /etc/redhat-release ] ; then
	PYTHON=python2.6
else
	PYTHON=python
fi

if URL=`$PYTHON ./get_XMM_obs_url.py $1` ; then
	wget $URL
	if [ "`echo $URL | grep odf`" ] ; then
		mkdir -p $1/odf
		mv `basename $URL` $1/odf
	else
		tar xfv `basename $URL`
		rm `basename $URL`
	fi
fi
