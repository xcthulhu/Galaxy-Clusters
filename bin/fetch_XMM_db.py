#!/usr/bin/env python
import urllib,urllib2
from process_db import *

if __name__ == '__main__':
	vals =     {    """popupFrom""" : """Query Results""" ,
                        """tablehead""" : """name=heasarc_xmmmaster&description=XMM-Newton Master Log &url=http://heasarc.gsfc.nasa.gov/W3Browse/xmm-newton/xmmmaster.html&archive=Y&radius=15&mission=XMM-NEWTON&priority=2&tabletype=Observation""",
			"""varon""" : """ra, dec, obsid, time, estimated_exposure, subject_category, name, status, class""" ,
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
	good_table = make_good_table(text_table,"XMM")
	for row in good_table:
		print '\t'.join(row)
