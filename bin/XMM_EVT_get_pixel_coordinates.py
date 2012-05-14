#!/usr/bin/env python
import sys
import pyfits
from filter_annulus import makeProjection

if __name__ == "__main__":
    hdus = pyfits.open(sys.argv[1])
    ra = float(sys.argv[2])
    dec = float(sys.argv[3])
    proj = makeProjection(hdus)
    X,Y = proj.topixel((ra,dec))
    print int(X),int(Y)
    hdus.close()
