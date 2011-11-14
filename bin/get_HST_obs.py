#!/usr/bin/env python

import urllib2,ephem,sys
from plot_clusters import r2d

if __name__ == "__main__":
   gal = ephem.Galactic(sys.argv[1], sys.argv[2])
   eq = ephem.Equatorial(gal, epoch=ephem.J2000)
   url = "http://archive.stsci.edu/hst/search.php?RA=%f&DEC=%f&radius=%s&max_records=1000&outputformat=CSV&action=Search" % (r2d(eq.ra), r2d(eq.dec), sys.argv[3])
   #print url
   mast = urllib2.urlopen(url)
   print mast.read()
