#!/bin/sh -x

URL=`./get_XMM_obs_url.py $1`
wget $URL
mv `basename $URL` XMM-$1.tar
tar xfv XMM-$1.tar
rm XMM-$1.tar
