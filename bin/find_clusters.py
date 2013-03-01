#!/usr/bin/env python
import csv,sys,os,cPickle,ephem
import numpy as np
from numpy import sqrt,sin,cos,arctan2,pi,arccos
from functools import partial
from fastcluster import *
from scipy.cluster.hierarchy import to_tree
if sys.version_info < (2, 4, 0): 
    from sets import Set as set 
from master_variables import *

def degToRad(x) : return x / 360. * 2 * pi

def arcminToRad(x) : return x * 0.000290888209
	
def GalToRad(lon,lat) :
	c = ephem.Galactic(lon,lat,epoch=ephem.J2000)
	return (float(c.lon),float(c.lat))

# Vincenty's formula for great circle distance 
# (same as greatCircleD but numerically stable)
def Vincenty((phi1,lam1),(phi2,lam2)) :
	dlam = lam1 - lam2
	return arctan2(sqrt((cos(phi2)*sin(dlam))**2 + (cos(phi1)*sin(phi2) - sin(phi1)*cos(phi2)*cos(dlam))**2),
                     sin(phi1)*sin(phi2) + cos(phi1)*cos(phi2)*cos(dlam))

# Converts a line of data into a pair of coordinates
def lineToPair(l,cols=(1,2)) : 
	return GalToRad(l[cols[0]],l[cols[1]])

# Converts derived data from a tsv to an array of (unique) vectors
def dataToArray(data,cols) :
	s = set(map(partial(lineToPair,cols=cols),data))
	return np.array(list(s))

# Computes the distance matrix from an array of two vectors given a distance function
def distMat(data,metric) :
	m = np.zeros((len(data),len(data)))
	for i in range(len(data)) :
		for j in range(len(data)) :
			m[i][j] = metric(data[i],data[j])
	return m

# Gets all pairs from a list
def pairs(L):
	while L:
		i = L.pop()
		for j in L: yield i, j

# Takes a scipy.cluster.hierarchy.ClusterNode (ie, a tree)
# and returns a lazy list of leaves
def leaves(cls) :
	if cls == None : return []
	if cls.is_leaf() : return [cls.id]
	else : return leaves(cls.left) + leaves(cls.right) 

# Takes a ClusterNode tree 
# and returns a list of lists of ids, seperated by the given distance
# (forms a paritition over the leaves)
def getLevel(cls,d) : 
   if cls == None : return []
   if cls.dist <= d : 
      return [leaves(cls)]
   else : return getLevel(cls.left, d) + getLevel(cls.right, d)

# Takes the modulus of some data using a partition and a membership function
def modData(data, part, memF) :
	l = map(lambda x : [], part)
	for x in data :
		for n in range(len(part)) :
			if memF(x,part[n]) : 
				l[n].append(x)
				break
	return l
	
# Clusters the entries in a file
# Default is pretty wide
def mkClusters(filename,radius=RADIUS,cpDir="checkpoints",cols=(1,2)) :
	# radius given in arcmins
	f = open(filename)
	data = list(csv.reader(f, delimiter='\t'))

	if not os.path.exists(cpDir): os.makedirs(cpDir)

	# We check if pickled data-products exist before computing
	if os.path.exists(cpDir + "/" + filename + ".vec") :
		vecs_file = open(cpDir + "/" + filename + ".vec", 'r')
		print "Loading vector from file..."
		vecs = cPickle.load(vecs_file)
		vecs_file.close()
	else:
		print "Computing vectors..."
		vecs = dataToArray(data,cols=cols)
		print "Saving vectors to file..."
		vecs_file = open(cpDir + "/" + filename + ".vec", 'w')
		cPickle.dump(vecs, vecs_file)
		vecs_file.close()

	if os.path.exists(cpDir + "/" + filename + ".tree") :
		print "Loading tree from file..."
		tree_file = open(cpDir + "/" + filename + ".tree", 'r')
		tree = cPickle.load(tree_file)
		tree_file.close()
	else:
		print "Computing tree..."
		tree = to_tree(linkage(vecs, metric=Vincenty, method='complete'))
		print "Saving tree to file..."
		tree_file = open(cpDir + "/" + filename + ".tree", 'w')
		cPickle.dump(tree, tree_file)
		tree_file.close()

	if os.path.exists(cpDir + "/" + filename + ("%f.part" % radius)) :
		print "Loading partition from file..."
		part_file = open(cpDir + "/" + filename + ("%f.part" % radius), 'r')
		part = cPickle.load(part_file)
		part_file.close()
	else:
		print "Computing partition..."
		lol = getLevel(tree, arcminToRad(radius))
		part = [ map(lambda n : vecs[n], x) for x in lol ]
		print "Saving partition to file..."
		part_file = open(cpDir + "/" + filename + ("%f.part" % radius), 'w')
		cPickle.dump(part, part_file)
		part_file.close()

	if os.path.exists(cpDir + "/" + filename + ("%f.cls" % radius)) :
		print "Loading individual clusters from file..."
		cluster_file = open(cpDir + "/" + filename + ("%f.cls" % radius), 'r')
		myCluster = cPickle.load(cluster_file)
		cluster_file.close()
	else :
		print "Computing individual clusters..."
		memF = lambda x,p : any(map(lambda y : lineToPair(x,cols=cols) == (y[0],y[1]),p))
		myCluster = modData(data, part, memF)
		cluster_file = open(cpDir + "/" + filename + ("%f.cls" % radius), 'w')
		print "Saving individual clusters to file..."
		cPickle.dump(myCluster, cluster_file)
		cluster_file.close()

	f.close()
	return myCluster


# Write clusters out to directories
def writeClusters(cls,clustersDir="clusters"):
	for c in cls:
		clusterName=(c[0][1]+c[0][2]).replace(':','_')
		thisDir=os.path.join(clustersDir,clusterName)
		if not os.path.exists(thisDir): os.makedirs(thisDir)
		newfn = os.path.join(thisDir,clusterName+".tsv")
		f = open(newfn,'w')
		print >>f, "\n".join(map(lambda x: "\t".join(x),c))
		print "Wrote:", newfn 
		f.close()
