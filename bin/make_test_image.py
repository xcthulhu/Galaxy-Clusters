#!/usr/bin/env python
import numpy as np
import sys, errno
from random import uniform
from scipy.misc import toimage
from collections import defaultdict
from itertools import combinations, product

def make_test_image(shape, freq):
	"""make_test_image(shape, frequency)
	
	- Outputs: A binary numpy array m where m.shape == shape and

	  (# of non-zero points)
	   ---------------------   == freq
	      total points
	  
	  the points are uniformly distributed"""
	def maybe(x) : 
		if uniform(0,1) < freq : return 1
		else : return 0
	m = np.zeros(shape)
	return np.vectorize(maybe)(m)

def translate(m,(ytr,xtr)):
	"""translate (m,(ytr,xtr)) 

	- Outputs: a translated image matrix of m"""
	w,h = m.shape[0], m.shape[1]
	n = np.zeros(m.shape)
	if not ( (-w <= xtr <= w) and (-h <= ytr <= h)) :
		raise NameError("OutOfBounds")
	# Python slices; if you don't know what this is please read:
	# http://stackoverflow.com/questions/509211/good-primer-for-python-slice-notation
	if (0 <= xtr and 0 <= ytr) : n[xtr:,ytr:] = m[:w-xtr,:h-ytr]
	elif (0 > xtr and 0 <= ytr) : n[:w+xtr,ytr:] = m[-xtr:,:h-ytr]
	elif (0 <= xtr and 0 > ytr) : n[xtr:,:h+ytr] = m[:w-xtr,-ytr:]
	elif (0 > xtr and 0 > ytr) : n[:w+xtr,:h+ytr] = m[-xtr:,-ytr:]
	return n

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

if __name__ == '__main__':
	if len(sys.argv) < 6:
		print >>sys.stderr, "Usage: %s x-dimension y-dimension frequency x-translation y-translation" % sys.argv[0]
		sys.exit(errno.EINVAL)
	shape = (int(sys.argv[1]),int(sys.argv[2]))
	trans = (int(sys.argv[4]),int(sys.argv[5]))
	mydist = lambda pt0,pt1: round(euclidean(pt0,pt1),2)

	# Simulation
	m = make_test_image(shape,float(sys.argv[3]))
	mtr = translate(m,trans)
	#toimage(translate(m,trans)).show()
	h = corr_hash(m,mtr)
	vals = sorted(h.values())
	#print len(get_dist_hash(m,dist=mydist)).keys())
