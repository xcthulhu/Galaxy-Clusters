#!/usr/bin/env python

import urllib,urllib2,sys

def get_HST(lon,lat,rad):
	url = "http://archive.stsci.edu/hst/search.php?RA=36.821&DEC=-40.933&radius=30&sci_spec_1234=*F814*&sci_instrume=ACS&max_records=5000&selectedColumnsCsv=sci_data_set_name,sci_ra,sci_dec&outputformat=CSV&action=Search"

	req = urllib2.Request(url, params)
	f = urllib2.urlopen(req)
	print params
	#print f.read()

if __name__ == '__main__':
	get_HST(sys.argv[1],sys.argv[2],sys.argv[3])
	#print sys.argv[1]
