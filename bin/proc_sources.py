#!/usr/bin/env python

import sys
import numpy as np
import os
import glob

bands = [350.0, 750.0, 1500.0, 3250.0, 8250.0]

def ranks(photon_files):
	data = [(obsid,np.loadtxt(f)) 
                for (obsid,f) in photon_files]
	while len(data) >= 5:
		print [p for p,_ in data]
	        data.pop()

if __name__ == "__main__":
	#print sys.argv[1], sys.argv[2]
	# Get the list of sources
	if len(sys.argv) >= 2:
	  sourcesfn = sys.argv[1]
	else:
	  sourcesfn = "sources.txt"

	sourcesf = open(sourcesfn)
	source_list = [map(lambda x: x.strip(), i.split('\t')) 
		           for i in sourcesf.readlines()]
	sourcesf.close()
	# Get the list of chandra obsids
	if len(sys.argv) >= 3:
	   obsfn = sys.argv[2]
	else:
	   obsfn = os.path.basename(os.getcwd()) + ".tsv"
	obsf = open(obsfn)
	OBSIDS = [ int(l[3]) 
                   for l in [l.split('\t') for l in obsf.readlines()] 
                   if l[0] == 'chandra' ]
	obsf.close()
	OBSIDS.sort()
	OBSIDS.reverse()
	print len(OBSIDS), "chandra observations total"
	# For each source
	for s in source_list[:10]:
	  # For each energy band
	  print "Checking source: ", s
	  for b in bands:
            photon_files = []
	    for obsid in OBSIDS:
	      ra,dec = s
              # Get the flux file
	      fluxfile = \
               os.path.join('chandra', str(obsid), 'science', 'fluxes',
                            "{ra}_{dec}_*_{band}".format(ra=ra, dec=dec,band=b),
                            "foreground_fluxp.txt")
              # Should be unique... still, we need a glob
              for f in glob.glob(fluxfile): 
                 # If it is not empty, add it on to photon_files
	         if os.stat(f).st_size != 0: photon_files.append((obsid,f))
	    print "found", len(photon_files), "non-empty flux files in band", b, \
                  ":", map(lambda x: x[0],photon_files)
            # If we have enough files, process
	    if len(photon_files) >= 5:
	      ranks(photon_files)
