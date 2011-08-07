#!/usr/bin/env python
import csv,sys
import numpy as np
from math import sqrt,sin,cos,atan2,pi,acos
from cluster import *

def degToRad(x) : return x/360. * 2 * pi

# Crappy formula for great circle distance based on law of cosines
# (for debugging Vincenty formula code - do not use!)
def greatCircleD(phi1,lam1,phi2,lam2) :
	dlam = lam1 - lam2
	return acos(sin(phi1)*sin(phi2) + cos(phi1)*cos(phi2)*cos(dlam))

# Vincenty's formula for great circle distance 
# (same as greatCircleD but numerically stable)
def Vincenty(phi1,lam1,phi2,lam2) :
	dlam = lam1 - lam2
	return atan2(sqrt((cos(phi2)*sin(dlam))**2 + (cos(phi1)*sin(phi2) - sin(phi1)*cos(phi2)*cos(dlam))**2),
                     sin(phi1)*sin(phi2) + cos(phi1)*cos(phi2)*cos(dlam))

# Takes two tsv lines with RA and DEC as columns 1 and 2 
# and computes great arc length
def tsvDist(line1,line2) : 
	return Vincenty(*map((lambda x: degToRad(float(x))),
                              line1[1:3]+line2[1:3]))

# Gets all pairs from a list
def pairs(L):
	while L:
		i = L.pop()
		for j in L: yield i, j

if __name__ == "__main__":
	data = csv.reader(open(sys.argv[1]), delimiter='\t')
	cl = HierarchicalClustering(list(data), tsvDist)
	print len(cl.getlevel(.012))
