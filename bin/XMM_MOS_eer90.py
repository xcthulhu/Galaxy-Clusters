#!/usr/bin/env python
import sys
import numpy as np
import pyfits
from XMM_eer90 import fits_dist, mos_eer90

if __name__ == "__main__":
	# Get the FITS file we are interested in
	fits_fn = sys.argv[1] 
	# Load the sources
	sources = np.reshape(np.loadtxt(sys.argv[2]),(-1,2)) 
	# Get the energy bands from command line
	energies = map(lambda x : float(x)/1000.,sys.argv[3:]) 
	# Load the FITS file
	f = pyfits.open(fits_fn) 
	# Nominal boresight RA in degs
	ra_nom = f['EVENTS'].header['RA_NOM'] 
	# Nominal boresight DEC in degs
	dec_nom = f['EVENTS'].header['DEC_NOM'] 
	f.close()
	# Compute the distance from each source to the boresight
	dists = fits_dist(sources[:,0], sources[:,1], ra_nom, dec_nom) 
	# Compute the 90% encircling energy radii
	radii = np.hstack([sources] + map(lambda e : np.reshape(np.vectorize(mos_eer90)(e,dists),(-1,1)), energies)) 
	# Print the data to commandline
	np.savetxt(sys.stdout,radii,fmt="%10f",delimiter="\t") 
