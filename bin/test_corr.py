#!/usr/bin/env python
import numpy as np
import sys, errno
from random import uniform
from scipy.misc import toimage
from correspondents import corr_hash, get_points

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

if __name__ == '__main__':
	if len(sys.argv) < 6:
		print >>sys.stderr, "Usage: %s x-dimension y-dimension frequency x-translation y-translation" % sys.argv[0]
		sys.exit(errno.EINVAL)
	shape = (int(sys.argv[1]),int(sys.argv[2]))
	trans = (int(sys.argv[4]),int(sys.argv[5]))
	mydist = lambda pt0,pt1: round(euclidean(pt0,pt1),1)

	# Simulation
	m = make_test_image(shape,float(sys.argv[3]))
	mtr = translate(m,trans)
	#toimage(translate(m,trans)).show()
	h = corr_hash(m,mtr)
	orig_pts = len(list(get_points(m)))
	vals = h.values()
	ran = np.max(vals) - np.min(vals)
	corrs = len(filter(lambda x: x >= ran * .5, vals))
	print float(corrs) / orig_pts
	#print len(get_dist_hash(m,dist=mydist)).keys())
