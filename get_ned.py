#!/usr/bin/env python
import urllib,urllib2,sys
from astropysics.coords.coordsys import LatLongCoordinates
from math import pi
import ephem
from master_variables import *
import StringIO

def d2r(deg) : return deg / 360. * 2 * pi

def isFloat(x):
	try:
		float(x)
		return True
	except: return False

def get_ned(lon,lat,radius=RADIUS):
	# radius is in arcmins
	url = 'http://ned.ipac.caltech.edu/cgi-bin/nph-objsearch?in_csys=' + COORD_SYSTEM + '&in_equinox=J2000.0&lon=' + urllib.quote(lon) + '&lat=' + urllib.quote(lat) + '&radius=' + ("%f" % radius) + '&hconst=73&omegam=0.27&omegav=0.73&corr_z=1&search_type=Near+Position+Search&z_constraint=Unconstrained&z_value1=&z_value2=&z_unit=z&ot_include=ANY&nmp_op=ANY&out_csys=' + COORD_SYSTEM + '&out_equinox=J2000.0&obj_sort=Distance+to+search+center&of=ascii_tab&zv_breaker=30000.0&list_limit=5&img_stamp=NO'
	response = urllib2.urlopen(url)
	raw = response.read()
	obs = [ l.split('\t')[1:] for l in raw.split('\n')[24:-1] ]
	def h(l) : # helper function
		if (l[5] == '') : l[5] = "NOZ"
		if isFloat(l[1]) and isFloat(l[2]):
			gal = ephem.Galactic(d2r(float(l[1])),d2r(float(l[2])),epoch=ephem.J2000)
			lonstr = StringIO.StringIO() ; latstr = StringIO.StringIO() 
			print >>lonstr, gal.lon ; print >>latstr, gal.lat
			l[1]=lonstr.getvalue().strip() ; l[2]=latstr.getvalue().strip() 
		return l
	zobs = map(h, obs) # Didn't have to be functional; could have used a loop I suppose
	return zobs

if __name__ == '__main__':
	obs = get_ned(sys.argv[1],sys.argv[2])
	print "\n".join(map(lambda line : '\t'.join(line), obs))
