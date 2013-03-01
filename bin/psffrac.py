#!/usr/bin/env python

# CIAO must be initialized before running this!

from ciao_contrib.runtool import dmcoords
from ciao_contrib.runtool import calquiz
import psf
import sys

def_en = 1.0
def_frac = 0.9

if __name__ == "__main__" :
	if len(sys.argv) < 4:
		sys.stderr.write('Need at least 4 parameters!\n')
		sys.exit(1)

	evt = sys.argv[1]
	asol= sys.argv[2]
	ra = sys.argv[3]
	dec = sys.argv[4]

	if len(sys.argv) > 5:
		energy = float( sys.argv[5] ) / 1000.
	else:
		energy = def_en

	if len(sys.argv) > 6:
		frac = float( sys.argv[6] )
	else:
		frac = def_frac

	dmcoords.punlearn()
	dmcoords.infile = evt
	dmcoords.asolfile = asol
	dmcoords.ra = ra
	dmcoords.dec = dec
	dmcoords.celfmt = "deg"
	dmcoords.opt = "cel"
	dmcoords()

	theta = dmcoords.theta
	phi = dmcoords.phi

	calquiz(telescope="CHANDRA", product="REEF")
	reef=calquiz.outfile
	pdata=psf.psfInit(reef)
	e=psf.psfSize(pdata,energy,theta,phi,frac)
	print("{0}".format(e))
	psf.psfClose(pdata)
