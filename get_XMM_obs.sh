#!/bin/sh -x

if [ -e /etc/redhat-release ] ; then
	PYTHON=python2.6
else
	PYTHON=python
fi

if URL=`$PYTHON ./get_XMM_obs_url.py $1` ; then
	wget $URL
	mv `basename $URL` XMM-$1.tar
	tar xfv XMM-$1.tar
	rm XMM-$1.tar
fi
