#!/usr/bin/env python

import sys, os, StringIO, ephem
import numpy as np
from fastcluster import *
from find_clusters import degToRad, Vincenty, getLevel, arcminToRad
from scipy.cluster.hierarchy import to_tree
from math import pi

def get_srcs(infns):
    """Gets all the sources from a list of files, returns an enormous array"""
    data = [ np.reshape(np.loadtxt(fn),(-1,2)) 
             for fn in infns if os.path.isfile(fn) 
                             and os.path.getsize(fn) > 0 ]
    if data == [] : return []
    else : return np.concatenate(data)

def srcDist(src1, src2):
    """Gets the distance between two srcs"""
    return Vincenty((degToRad(src1[0]),degToRad(src1[1])),
                    (degToRad(src2[0]),degToRad(src2[1])))

def arcsecToRad(arcsec): return pi/648000 * arcsec

if __name__ == "__main__":
	data = get_srcs(sys.argv[2:])
	if len(data) <= 1 : srcs = data
	elif len(data) > 1 :
    		tree = to_tree(linkage(data, metric=srcDist, method='complete'))
		idxs = map(lambda i : i[0], getLevel(tree,arcsecToRad(float(sys.argv[1]))))
		srcs = data[idxs]
	for (RA,DEC) in srcs : print RA,"\t",DEC
