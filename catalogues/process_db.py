#!/usr/bin/env python
import time,ephem
from math import pi
import urllib,urllib2

def isTime(string):
	try:
		time.strptime(string,"%Y-%m-%d %H:%M:%S")
		return True
	except ValueError:
		return False

def degToRad(d) : return d / 360. * 2 * pi

# Determine whether an entry is on the galactic plane (approximately)
def offGP(l,zoneOfAvoidance=15) :
	eq = ephem.Equatorial(l[1],l[2]) # Equitorial coordinates
	gal = ephem.Galactic(eq)        # Galatic coordinates
	return abs(gal.lat) >= degToRad(zoneOfAvoidance)

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

	# throw out the "Zone of Avoidance"
	table4 = filter(offGP, table3)

	return [header] + table4

if __name__ == '__main__':
	vals =     {    """popupFrom""" : """Query Results""" ,
                        """tablehead""" : """ name=heasarc_chanmaster&description=Chandra Observations&url=http://heasarc.gsfc.nasa.gov/W3Browse/chandra/chanmaster.html&archive=Y&radius=21&mission=CHANDRA&priority=1&tabletype=Observation""",
                        """varon""" : """ra, dec, obsid, time, exposure, category, name, status, detector""" ,
			"""Coordinates""" : """J2000""" ,
			"""Radius""" : """Default""" ,
			"""Radius_unit""" : """arcsec""" ,
			"""NR""" : """CheckCaches/GRB/SIMBAD/NED""" ,
			"""Time""" : "" ,
			"""ResultMax""" : """0""" ,
			"""displaymode""" : """PureTextDisplay""" ,
			"""Action""" : """Start Search""" ,
			"""table""" : """heasarc_chanmaster""" }
	url='http://heasarc.gsfc.nasa.gov/db-perl/W3Browse/w3query.pl'
	post_data = urllib.urlencode(vals)
	req = urllib2.Request(url, post_data)
	response = urllib2.urlopen(req)
	text_table = response.read()
	good_table = make_good_table(text_table,"chandra")
	for row in good_table:
		print '\t'.join(row)
