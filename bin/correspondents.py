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

def euclidean(v0,v1):
	"""euclidean(pt0,pt1)
	- Outputs: The Euclidean distance between pt0 and pt1"""
	v_ = np.array(v0) - np.array(v1) 
	return np.sqrt(np.dot(v_,v_))

def get_dist_hash(m, ndigits=2,dist=euclidean):
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
		h[round(dist(pt1,pt2),ndigits)].add(frozenset([pt1,pt2]))
	return h

def corr_hash(m_ref,m_obs, ndigits=2,dist_ref=euclidean, dist_obs=euclidean):
	"""corr_hash(mref,mobs)
	- Outputs: A hash table of points in m0 and corresponding points in m1"""
	hm1dist = get_dist_hash(m_obs,ndigits=ndigits,dist=dist_obs)
	hcorr = defaultdict(int)
	for (po0,po1) in combinations(get_points(m_ref),2):
		for (pd0,pd1) in hm1dist[round(dist_ref(po0,po1),ndigits)]:
			hcorr[(po0,pd0)] += 1
			hcorr[(po0,pd1)] += 1
			hcorr[(po1,pd0)] += 1
			hcorr[(po1,pd1)] += 1
	return hcorr

def correspondents_naive(mref,mobs,ndigits=1,dist_ref=euclidean,dist_obs=euclidean,thresh=.70):
	"""correspondents_naive(mref,mobs)
	- Ouputs: A generator of detected corresponding pairs in mref and mobs [not necessarily 1-1, so might be bad]"""
	h = corr_hash(mref, mobs, ndigits=ndigits, dist_ref=dist_ref, dist_obs=dist_obs)
	vals = h.values()
	med = float(np.median(vals))
	for k,v in h.iteritems() :
		if 1 - med / v >= thresh : yield k

def correspondents(mref,mobs,ndigits=1,dist_ref=euclidean,dist_obs=euclidean,thresh=.70):
	"""correspondents_bad(mref,mobs)
	- Ouputs: A generator of detected corresponding pairs in mref and mobs"""
	h = corr_hash(mref, mobs, ndigits=ndigits, dist_ref=dist_ref, dist_obs=dist_obs)
	med = float(np.median(h.values()))
	forth = defaultdict(bool) ; back = defaultdict(bool)
	# Can't be lazy here - default-dicts have a quantum mechanical bug 
	# where if you try to read them you change them
	for (pref,pobs),v in list(h.iteritems()) :
		if 1 - med / v >= thresh : 
			# The following logic ensures that we output 1-1 correspondents, 
			# always using the best matches we have detected
			# (remember that h is a defaultdict that defaults to 0)
			if     v > h[(pref,forth[pref])] \
			   and v > h[(back[pobs],pobs)] :
				   #print pref, pobs
				   if back[forth[pref]] : del back[forth[pref]]
				   if forth[back[pobs]] : del forth[back[pobs]]
				   forth[pref] = pobs
				   back[pobs] = pref
	print list(forth.iteritems())
	return filter(lambda (x,y) : x and y , forth.iteritems())
