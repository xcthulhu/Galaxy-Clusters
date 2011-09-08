#!/usr/bin/env python
import urllib,urllib2
from process_db import *
from master_variables import *

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
