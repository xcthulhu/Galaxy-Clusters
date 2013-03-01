#!/usr/bin/env python

import numpy as np
import sys

def mk_src_reg(fn,ra_dec_rad) : 
	"""Input: a filename, RA, DEC and (presumably 90% encircling energy) radius of point source spread
	   Writes (to filename) : A ds9 region file of the corresponding circle around source
	     RA, DEC in fk5 degrees
	     Radius is in arcseconds
        """
	f = open(fn,'w')
	print >>f, "fk5"
	for (ra,dec,rad) in ra_dec_rad:
		print >>f, "circle(%f,%f,%f\")" % (ra,dec,rad)
	f.close()

def mk_bkg_reg(fn,ra_dec_rads) :
	"""Input: a filename, RA, DEC and (presumably 90% encircling energy) radius of point source spread
	   Writes (to filename) : A ds9 region file of the corresponding background region (annulus)
	     RA, DEC in fk5 degrees
	     Radius is in arcseconds
        """
	f = open(fn,'w')
	print >>f, "fk5"
	for (ra,dec,rad1,rad2) in ra_dec_rads:
		print >>f, "circle(%f,%f,%f\")" % (ra,dec,rad1,rad2)
	f.close()

if __name__ == "__main__" : 
	master_sizes = np.loadtxt(sys.argv[1])
	bands = sys.argv[2:]
	rs = dict(zip(bands,np.transpose(master_sizes)[2:]))
	ra,dec = master_sizes.T[0:2]
	for b in bands: 
		mk_src_reg(b + "_srcs.reg", np.array([ra,dec,rs[b] / 2.]).T[rs[b] != -1])
