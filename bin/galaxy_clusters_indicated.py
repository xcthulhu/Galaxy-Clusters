#!/usr/bin/env python

import sys,pyfits
import ephem
from kapteyn import maputils,wcs
from math import pi
from itertools import product

if __name__ == "__main__":
	gal = ephem.Galactic (sys.argv[2],sys.argv[3])
	eq = ephem.Equatorial(gal, epoch='2000')
	ra = float(eq.ra) / pi *180;
	dec = float(eq.dec) / pi *180;

	HST_img = pyfits.open(sys.argv[1])
	fits_img = maputils.FITSimage(externalheader=HST_img[1].header,externaldata=HST_img[1].data)
	img = fits_img.Annotatedimage(cmap="bone")
	proj = wcs.Projection(HST_img[1].header,skyout="equatorial fk5 J2000")
	img.Image()
	img.Graticule()
	
	w,h = HST_img[1].data.shape[0], HST_img[1].data.shape[1]
	#print gal.lon, gal.lat
	#print projection.skysys, projection.skyout
	print ra,dec, "   ", eq.ra,eq.dec
	print map(proj.toworld, product([0,w],[0,h]))
	
	#print img.topixel(round(ra),round(dec))
 	#print img.projection.topixel((ra,dec))	
 	#print img.projection.topixel((ra,dec))	
