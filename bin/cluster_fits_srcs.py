#!/usr/bin/env python

import pyfits, sys, os, StringIO, ephem
import numpy as np
from fastcluster import *
from find_clusters import degToRad, Vincenty, getLevel, arcminToRad
from scipy.cluster.hierarchy import to_tree
from math import pi

def update_srcs(infn, srcs=None, header=None, outfn=None):
    """Updates a srcs FITS file"""
    inf = pyfits.open(infn)
    if outfn == None:
       outfn = "updated-" + os.path.basename(infn)
    pyfits.writeto(outfn, inf[0].data, inf[0].header)
    pyfits.append(outfn, srcs , inf[1].header)
    inf.close()

def get_srcs(infns):
    """Gets all the sources from a list of files, returns an enormous array"""
    fits = map(lambda x: pyfits.open(x), infns)
    data = np.concatenate(map(lambda f: np.array(f[1].data), fits))
    map(lambda f: f.close(), fits)
    return data

def srcDist(src1, src2):
    """Gets the distance between two srcs"""
    return Vincenty((degToRad(src1[0]),degToRad(src1[1])),
                    (degToRad(src2[0]),degToRad(src2[1])))

def arcsecToRad(arcsec): return pi/648000 * arcsec

if __name__ == "__main__":
    srcs = get_srcs(sys.argv[3:])
    positions = np.array(map(lambda x: (x[0],x[1]), srcs))
    tree = to_tree(linkage(positions, metric=srcDist, method='complete'))
    clustered_srcs = map(lambda x: np.array(map(lambda y: srcs[y], x),dtype=srcs.dtype), getLevel(tree,arcsecToRad(float(sys.argv[1]))))
    if not os.path.exists(sys.argv[2]):
       os.makedirs(sys.argv[2])
    for cls in clustered_srcs:
      g = ephem.Galactic(ephem.Equatorial(cls[0][0]/180 * pi, cls[0][1]/180 * pi))
      lat,lon = StringIO.StringIO(),StringIO.StringIO()
      print >>lat, g.lat ; print >>lon, g.lon
      outfn = '%s/%s-%s-R%g_srcs.fits' % (sys.argv[2],
		      lon.getvalue().strip().replace(":","_"), 
		      lat.getvalue().strip().replace(":","_"),
		      float(sys.argv[1]))
      update_srcs(sys.argv[3],srcs=cls,outfn=outfn) 
      print "Wrote:", outfn 
    #print get_srcs(sys.argv[2:])
