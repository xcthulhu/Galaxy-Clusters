#!/usr/bin/env python
import sys
import os
import pyfits
import numpy as np
from numpy import pi
from filter_annulus import getRotatedEvents

def goodBackgroundEvents(hdu, ra, dec, r1=130, r2=160, sections=12):
    """Computes good background events in an annulus around RA and DEC in hdu
        - RA and DEC should be given in degrees in J2000
        - R1 and R2 should be given in arcseconds
        - sections must be given as an integer"""
    r1_ = (pi / 648000.) * r1
    r2_ = (pi / 648000.) * r2
    rot_evts = getRotatedEvents(hdu, ra, dec)
    # Select the annulus of events we want
    annulus_idx = (r1_ <= rot_evts[:,1]) & (rot_evts[:,1] <= r2_)
    annulus = hdu['events'].data[annulus_idx]
    annulus_rot_evts = rot_evts[annulus_idx]
    # Compute the mean and standard deviation of the annulus
    mu = np.average(annulus['pi'])
    sigma = np.std(annulus['pi'])
    # Compute an index of good sections of the annulus (mean not too high)
    good_annulus_idx = np.zeros(len(annulus_rot_evts), dtype=bool)
    start = 0
    for end in 2. * pi / sections * np.arange(1,sections+1):
        section_idx = (start <= annulus_rot_evts[:,0]) & \
                      (annulus_rot_evts[:,0] <= end)
        if any(section_idx) and \
           (abs(mu - np.average((annulus[section_idx])['pi'])) < sigma):
            good_annulus_idx |= section_idx
        start = end
    return annulus[good_annulus_idx]

if __name__ == "__main__":
    if (len(sys.argv) < 7) :
        print >> sys.stderr, \
            """Insufficient command line arguments.
               Need: <input_XMM_EVT.fits> RA DEC R1 R2 <output_XMM_EVT.fits>
               - RA and DEC should be given in degrees
               - R1 and R2 should be given in arcseconds"""
        sys.exit(1)
    hdu = pyfits.open(sys.argv[1])
    ra = float(sys.argv[2])
    dec = float(sys.argv[3])
    r1 = float(sys.argv[4])
    r2 = float(sys.argv[5])
    hdu['events'].data = goodBackgroundEvents(hdu, ra, dec, r1, r2)
    try : os.remove(sys.argv[6])                                                                                                          
    except : pass                                                                                                                         
    hdu.writeto(sys.argv[6])
    hdu.close()
