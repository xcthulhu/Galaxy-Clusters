#!/usr/bin/env python

import sys
import pyfits
import kapteyn.wcs as wcs
import numpy as np
import os
from numpy import pi, sqrt, cos, sin, arctan2
from matplotlib.mlab import amap
from kapteyn import maputils
from matplotlib import pyplot as plt
from random import shuffle

def rot(phi0,delta0,phi,delta) :
    """Rotates (phi,delta) to the frame where:
        (phi0,delta0) is the north pole (z-axis)
        (phi0 + pi/2,0) is the east pole (y-axis)
        (phi0 - pi/2,delta0) is the x-axis
        
        ...and declination is great circle distance from (phi0,delta0),
           and the right ascension is in [0,2*pi)"""
    cd0 = cos(delta0)
    cd = cos(delta)
    sd0 = sin(delta0)
    sd = sin(delta)
    cDp = cos(phi - phi0)
    sDp = sin(phi - phi0)
    newphi = arctan2(cd*sDp, -cd0*sd + cd*sd0*cDp) % (2*pi)
    newdelta = arctan2(sqrt((-cd0*sd*cDp + cd*sd0)**2 + cd0**2 * sDp**2), 
                        cd*cd0*cDp + sd*sd0) % (2*pi)
    return np.hstack((newphi.reshape(-1,1),newdelta.reshape(-1,1)))

def goodXMMFITSHeader(hdr):
    """Creates a pyfits header from an XMM file"""
    return {
        'NAXIS': 2,
        'NAXIS1': 648,
        'NAXIS2': 648,
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

def makeProjection(hdus):
    """Return a wcs projection object based on the XMM event header keys"""
    return wcs.Projection(goodXMMFITSHeader(hdus['events'].header))

def getWorldEventsInRadians(hdus):
    """Return the events in an XMM event file in world coordinates"""
    xin = hdus['events'].data.field('x')
    yin = hdus['events'].data.field('y')
    raw_coords = np.hstack((xin.reshape(-1,1), yin.reshape(-1,1)))
    proj = makeProjection(hdus)
    return (pi/180.)*proj.toworld(raw_coords)

def getRotatedEvents(hdus, ra, dec):
    """Returns the coordinates of events in hdus rotated so that the point
    specified by the RA and DEC is the north pole; RA/DEC must be specified in
    degrees"""
    ra_ = (pi / 180.) * ra
    dec_ = (pi / 180.) * dec
    wevts = getWorldEventsInRadians(hdus)
    return rot(ra_, dec_, *(wevts.transpose()))

def validAnnulusEventsData(hdus, ra, dec , r1, r2, theta1, theta2):
    """Returns a numpy array containing the valid events in hdus that are in the
    annulus section specified by the parameters as follows:
        - inner radius r1 (solid angle)
        - outer radius r2 (solid angle)
        - inner angle theta1
        - outer angle theta2

    Units:
        - RA and DEC must be given in degrees
        - r1 and r2 should be given in arcseconds
        - theta1 and theta2 should be given in degrees"""
    theta1_ = ((pi / 180.) * theta1) % (2*pi)
    theta2_ = ((pi / 180.) * theta2) % (2*pi)
    r1_ = (pi / 648000.) * r1
    r2_ = (pi / 648000.) * r2
    rotevts = getRotatedEvents(hdus, ra, dec)
    if (theta1_ < theta2_):
        idxs = (theta1_ <= rotevts[:,0]) & (rotevts[:,0] <= theta2_) & \
               (r1_ <= rotevts[:,1]) & (rotevts[:,1] <= r2_) 
    else:
        idxs = ((theta1_ <= rotevts[:,0]) | (rotevts[:,0] <= theta2_)) & \
               (r1_ <= rotevts[:,1]) & (rotevts[:,1] <= r2_) 
    return hdus['events'].data[idxs]

if __name__ == "__main__":
    if (len(sys.argv) < 9) :
        print >> sys.stderr, \
        """Insufficient command line arguments.
        Need: <input_XMM_EVT.fits> RA DEC R1 R2 THETA1 THETA2 <output_XMM_EVT.fits>
            - RA and DEC should be given in degrees
            - R1 and R2 should be given in arcseconds"""
        sys.exit(1)
    hdus = pyfits.open(sys.argv[1])
    ra, dec, r1, r2, theta1, theta2 = map(float,sys.argv[2:8])
    hdus['events'].data = validAnnulusEventsData(hdus, ra, dec, r1, r2, theta1, theta2)
    try : os.remove(sys.argv[8])
    except : pass
    hdus.writeto(sys.argv[8])
    hdus.close()
