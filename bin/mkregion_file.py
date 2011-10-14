#!/usr/bin/env python

import pyfits,sys

def extract_regions(fn):
	hdulist = pyfits.open(fn)
	for ln in hdulist[1].data:
		if ln['SHAPE'] == 'ellipse':
			yield "%s(%f,%f,%f,%f,%f)" %(ln['SHAPE'],ln['X'],ln['Y'],ln['R'][0],ln['R'][1],ln['ROTANG'])

if __name__ == '__main__':
	for obj in extract_regions(sys.argv[1]):
		print obj
