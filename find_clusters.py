#!/usr/bin/env python
import csv,sys,os,cPickle,ephem
import numpy as np
from math import sqrt,sin,cos,atan2,pi,acos
from fastcluster import *
from scipy.cluster.hierarchy import to_tree
from sets import Set

def degToRad(x) : return x / 360. * 2 * pi

def EqToRad(ra,dec) :
	c = ephem.Equatorial(ra,dec,epoch=ephem.J2000)
	return (float(c.ra),float(c.dec))

# Vincenty's formula for great circle distance 
# (same as greatCircleD but numerically stable)
def Vincenty((phi1,lam1),(phi2,lam2)) :
	dlam = lam1 - lam2
	return atan2(sqrt((cos(phi2)*sin(dlam))**2 + (cos(phi1)*sin(phi2) - sin(phi1)*cos(phi2)*cos(dlam))**2),
                     sin(phi1)*sin(phi2) + cos(phi1)*cos(phi2)*cos(dlam))

# Takes two tsv lines with RA and DEC (in degrees) as columns 1 and 2 
# and computes great arc length (in Radians)
def tsvDist(line1,line2) : 
	return Vincenty(*map((lambda x: degToRad(float(x))), line1[1:3]+line2[1:3]))

# Converts a line of data into a pair of coordinates
def lineToPair(l) : 
	return EqToRad(l[1],l[2])

# Converts derived data from a tsv to an array of (unique) vectors
def dataToArray(data) :
	s = Set(map(lineToPair,data))
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
	if cls.dist <= d : return [leaves(cls)]
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
def mkClusters(filename,clusterLvl=.004,cpDir="checkpoints") :
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
		vecs = dataToArray(data)
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

	if os.path.exists(cpDir + "/" + filename + ("%f.part" % clusterLvl)) :
		print "Loading partition from file..."
		part_file = open(cpDir + "/" + filename + ("%f.part" % clusterLvl), 'r')
		part = cPickle.load(part_file)
		part_file.close()
	else:
		print "Computing partition..."
		lol = getLevel(tree, clusterLvl)
		part = [ map(lambda n : vecs[n], x) for x in lol ]
		print "Saving partition to file..."
		part_file = open(cpDir + "/" + filename + ("%f.part" % clusterLvl), 'w')
		cPickle.dump(part, part_file)
		part_file.close()

	if os.path.exists(cpDir + "/" + filename + ("%f.cls" % clusterLvl)) :
		print "Loading individual clusters from file..."
		cluster_file = open(cpDir + "/" + filename + ("%f.cls" % clusterLvl), 'r')
		myCluster = cPickle.load(cluster_file)
		cluster_file.close()
	else :
		print "Computing individual clusters..."
		memF = lambda x,p : any(map(lambda y : lineToPair(x) == (y[0],y[1]),p))
		myCluster = modData(data, part, memF)
		cluster_file = open(cpDir + "/" + filename + ("%f.cls" % clusterLvl), 'w')
		print "Saving individual clusters to file..."
		cPickle.dump(myCluster, cluster_file)
		cluster_file.close()

	f.close()
	return myCluster


# Write clusters out to directories
def writeClusters(cls,clustersDir="clusters"):
	for c in cls:
		clusterName=c[0][1]+c[0][2]
		thisDir=os.path.join(clustersDir,clusterName)
		if not os.path.exists(thisDir): os.makedirs(thisDir)
		newfn = os.path.join(thisDir,clusterName+".tsv")
		f = open(newfn,'w')
		print >>f, "\n".join(map(lambda x: "\t".join(x),c))
		print "Wrote:", newfn 
		f.close()
	
if __name__ == "__main__":
	print "Computing Clusters"
	cls=mkClusters(sys.argv[1])
	print "Writing Cluster Directories"
	writeClusters(cls)
