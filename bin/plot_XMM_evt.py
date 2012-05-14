#!/usr/bin/env python

import sys
import pyfits
import kapteyn.wcs as wcs
import numpy as np
from kapteyn import maputils
from matplotlib import pyplot as plt
from random import shuffle
from find_clusters import Vincenty

def goodXMMFITSHeader(hdr):
    """Creates a pyfits header from an XMM file"""
    return {
        'NAXIS': 2,
        'NAXIS1': 2*hdr['REFXCRPX'],
        'NAXIS2': 2*hdr['REFYCRPX'],
        'CTYPE1': hdr['REFXCTYP'],
        'CRPIX1': hdr['REFXCRPX'],
        'CRVAL1': hdr['REFXCRVL'],
        'CDELT1': hdr['REFXCDLT'],
        'CUNIT1': hdr['REFXCUNI'],
        'CTYPE2': hdr['REFYCTYP'],
        'CRPIX2': hdr['REFYCRPX'],
        'CRVAL2': hdr['REFYCRVL'],
        'CDELT2': hdr['REFYCDLT'],
        'CUNIT2': hdr['REFYCUNI'],
    }

def randomSample(ar, n):
    """Randomly samples a numpy array without replacement"""
    index_array = np.arange(len(ar))
    shuffle(index_array)
    return ar[index_array[:n]]

def makeProjection(hdus):
    """Return a wcs projection object based on the XMM event header keys."""
    return wcs.Projection(goodXMMFITSHeader(hdus['events'].header))

if __name__ == "__main__":
    if (len(sys.argv) < 4) :
        print >> sys.stderr, \
        """Insufficient command line arguments.
        Need: <input_file.fits> <#_of_samples> <outputfile.pdf>"""
        sys.exit()
    hdus = pyfits.open(sys.argv[1])

    fitsobj = maputils.FITSimage(externalheader=goodXMMFITSHeader(hdus['events'].header))
    mplim = fitsobj.Annotatedimage()
    grat = mplim.Graticule()

    xin = hdus['events'].data.field('x')
    yin = hdus['events'].data.field('y')
    raw_coord = np.hstack((xin.reshape(-1,1), yin.reshape(-1,1)))
    samp = randomSample(raw_coord,int(sys.argv[2]))
    proj = makeProjection(hdus)
    coords = proj.toworld(samp)
    pts = grat.gmap.topixel(coords)
    x,y = np.transpose(pts)

    plt.plot(x,y,'o',color='red')

    mplim.plot()
    plt.savefig(sys.argv[3])
    hdus.close()
