#!/usr/bin/env python
import time,ephem,urllib,urllib2,StringIO
from math import pi
from master_variables import *

def isTime(string):
	try:
		time.strptime(string,"%Y-%m-%d %H:%M:%S")
		return True
	except ValueError:
		return False

def r2d(r) : return r / (2*pi) * 360

def makeGoodGalactic(lst, zoneOfAvoidance=ZONE_OF_AVOIDANCE) :
   for l in lst :
      # MAKE SURE THIS AGREES WITH WHAT HEASARC CLAIMS TO BE OUTPUTTING (should be Equatorial J2000) !!
      # MAKE SURE THIS IS USING THE SAME COORDINATES AS IS SPECIFIED IN master_variables.py !!!
      eq = ephem.Equatorial(l[1], l[2], epoch=ephem.J2000)
      gal = ephem.Galactic(eq)
      if ((r2d(gal.lat) <= -zoneOfAvoidance) or
          (zoneOfAvoidance <= r2d(gal.lat))) :
           lonstr = StringIO.StringIO() ; latstr = StringIO.StringIO()
	   print >>lonstr, gal.lon ; print >>latstr, gal.lat
           l[1] = lonstr.getvalue().strip()
	   if (gal.lat >= 0) : l[2] = "+" + latstr.getvalue().strip()
	   else : l[2] = latstr.getvalue().strip()
           yield l

# Determine whether an entry is on the galactic plane (approximately)
def offGP(l,zoneOfAvoidance=ZONE_OF_AVOIDANCE) :
	# MAKE SURE THIS AGREES WITH WHAT HEASARC CLAIMS TO BE OUTPUTTING (should be Equatorial J2000) !!
	# MAKE SURE THIS IS USING THE SAME COORDINATES AS IS SPECIFIED IN master_variables.py !!!
	eq = ephem.Equatorial(l[1], l[2], epoch=ephem.J2000)
	gal = ephem.Galactic(eq, epoch=ephem.J2000)
	return ((r2d(gal.lat) <= -zoneOfAvoidance) or (zoneOfAvoidance <= r2d(gal.lat)))

def cleanup_line(line, sat) :
	return [ cell.strip() for cell in line.split('|') ]

def make_good_table(text, sat) :
	lines = (text.splitlines())[4:]

	# lots of nice little lines
	table1 = map(lambda l : cleanup_line(l, sat), lines)

	# Note the header
	header = table1[0]
	header[0] = "satellite"

	# remember only the good times
	table2 = filter(lambda x : isTime(x[4]), table1[1:])

	# throw out bullshit RA/DECS
	table3 = filter(lambda x : not (x[1] == x[2] == ""), table2)

	# set the sattelite field and fix the RA/DECS
	for i in range(0,len(table3)):
		table3[i][0] = sat
		table3[i][1] = ':'.join(table3[i][1].split(' '))
		table3[i][2] = ':'.join(table3[i][2].split(' '))

	# Convert to Galactic Coordinates and chuck "the zone of avoidance"
	table4 = list(makeGoodGalactic(table3))

	return [header] + table4
