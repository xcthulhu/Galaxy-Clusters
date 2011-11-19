#!/usr/bin/env python
import numpy as np
import sys, errno
from random import uniform
from scipy.misc import toimage

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

def translate(m,(xtr,ytr)):
	"""translate (m,(xtr,ytr)) 

	- Outputs: a translated image matrix of m"""
	w,h = m.shape[0], m.shape[1]
	n = np.zeros(m.shape)
	n[xtr:,ytr:] = m[:w-xtr,:h-ytr]
	return n

def get_points(m) : 
	for (x,y) in product(range(m.shape[0]),range(m.shape[1])):
		if m[x][y] : yield (x,y)

def get_dist_hash(m,ndigits = 2):
	pts = list(get_points(m))
	h = {}
	try : h[d].append(set([pt1,pt2]))
	except : h[d] = [set([pt1,pt2])]

if __name__ == '__main__':
	if len(sys.argv) <= 6:
		print >>sys.stderr, "Usage: %s x-dimension y-dimension frequency x-translation y-translation" % sys.argv[0]
		sys.exit(errno.EINVAL)
	shape = (int(sys.argv[1]),int(sys.argv[2]))
	trans = (int(sys.argv[4]),int(sys.argv[5]))
	m = make_test_image(shape,float(sys.argv[3]))
	toimage(translate(m,trans)).show()
