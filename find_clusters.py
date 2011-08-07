#!/usr/bin/env python
import csv,sys,os
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

# Takes two tsv lines with RA and DEC (in degrees) as columns 1 and 2 
# and computes great arc length (in Radians)
def tsvDist(line1,line2) : 
	return Vincenty(*map((lambda x: degToRad(float(x))), line1[1:3]+line2[1:3]))

# Gets all pairs from a list
def pairs(L):
	while L:
		i = L.pop()
		for j in L: yield i, j

# Fixes a list of lists and singletons so it's a list of lists
def fixLoLHelper(badlol):
	for x in badlol:
		if isinstance(x,list): yield x
		else : yield [x]

def fixLoL(badlol):
	return list(fixLoLHelper(badlol))

# Write clusters out to directories
clustersDir="clusters"
def writeClusters(cls):
	for c in cls:
		clusterName=c[0][1]+c[0][2]
		thisDir=os.path.join(clustersDir,clusterName)
		if not os.path.exists(thisDir): os.makedirs(thisDir)
		newfn = os.path.join(thisDir,clusterName+".tsv")
		f = open(newfn,'w')
		print >>f, "\n".join(map(lambda x: "\t".join(x),c))
		print "Wrote:", newfn 
		f.close()
		
# Clusters the entry in a filename
# Pretty wide
clusterLvl=.012
def mkClusters(filename):
	f = open(filename)
	data = csv.reader(f, delimiter='\t')
	cl = HierarchicalClustering(list(data), tsvDist)
	outlol=fixLoL(cl.getlevel(clusterLvl))
	f.close()
	return outlol
	
if __name__ == "__main__":
	print "Computing Clusters"
	cls=mkClusters(sys.argv[1])
	print "Writing Cluster Directories"
	writeClusters(cls)
