#!/usr/bin/env python
import numpy as np
from collections import defaultdict
from itertools import combinations, product

def get_points(m) : 
	"""get_points(m)
	- Outputs: A generator of the points in m that correspond are not zero"""
	# If you don't understand generators:
	# http://wiki.python.org/moin/Generators
	for (x,y) in product(range(m.shape[0]),range(m.shape[1])):
		if m[x][y] : yield (x,y)

def euclidean((x0,y0),(x1,y1)):
	"""euclidean(pt0,pt1)
	- Outputs: The Euclidean distance between pt0 and pt1"""
	return np.sqrt((x0 - x1) ** 2 + (y0 - y1) ** 2)

def get_dist_hash(m,ndigits = 2,dist=euclidean):
	"""get_dist_hash(m, ndigits = 2, dist = euclidean)
	- Outputs: A hash table of sets of points in m that have the same distance from one another"""
	# defaultdict is awesome :D
	# http://docs.python.org/library/collections.html#collections.defaultdict
	h = defaultdict(set)

	# Also, itertools.combinations is sweet:
	# http://docs.python.org/library/itertools.html#itertools.combinations
	# Sets of sets in python are tricky - stackoverflow.com for the win
	# http://stackoverflow.com/questions/5931291/how-can-i-create-a-set-of-sets-in-python
	for (pt1,pt2) in combinations(get_points(m), 2):
		h[dist(pt1,pt2)].add(frozenset([pt1,pt2]))
	return h

def corr_hash(m0,m1,dist=euclidean):
	"""corr_hash(m0,m1)
	- Outputs: A hash table of points in m0 and corresponding points in m1"""
	hm1dist = get_dist_hash(m1,dist=dist)
	hcorr = defaultdict(int)
	for (po0,po1) in combinations(get_points(m0),2):
		for (pd0,pd1) in hm1dist[dist(po0,po1)]:
			hcorr[(po0,pd0)] += 1
			hcorr[(po0,pd1)] += 1
			hcorr[(po1,pd0)] += 1
			hcorr[(po1,pd1)] += 1
	return hcorr
