#!/usr/bin/env python

import pyfits,sys,StringIO,re

def parse_coords(fn):
	"""
	We assume that the input file is the output of the following command, using CIAO:
		> dmlist "<blah.fits>[cols ccd_id,EQPOS]" data rows=1:
	
	This outputs a table where each line looks like:

		<table_number> <ccd_in> ( <RA>, <DEC>)

	From this, we can parse the ccd_id, as well as the position in celestial coordinates using degrees."""
	# This utterly rediculous regular expression reads a line from the file
	re.compile("\S+\s+(\d+)\s+\(\s+(\d+\.\d+),\s+(\d+\.\d+)\)")


def evt2_to_RADEC(fn):
	"""Turn a CHANDRA evt2 FITS file into a TSV of celestial coordinate (ie, something useful)

	USEFUL REFERENCES FOR ARCANE NONSENSE:

	- What the CHANDRA FITS table entries actually mean
	    http://cxc.harvard.edu/ciao3.4/data_products_guide/event_descrip.html#acisl2evts

	- How to convert CHANDRA "sky coordinate system" into 
	  celestial coordinates
	    http://cxc.harvard.edu/ciao/threads/ds9/index.html#definitions
	"""
	fits = pyfits.open(fn)
	for i in range(len(fits)):
		out = StringIO.StringIO()
		print >>out, i
		try : print >>out, len(fits[i].data)
		except : print >>out, "N/A"
		try : print >>out, fits[i].columns.names
		except : print >>out, "N/A"
		print out.getvalue().replace('\n','\t')
		out.close()
	#print fits[1].data.field('X')

if __name__ == "__main__":
	evt2_to_RADEC(sys.argv[1])
