#!/usr/bin/env python
import sys
from numpy import pi,log
from find_clusters import Vincenty

# MOS detector
def mos1_5(d):
    """Returns XMM's 90% encircling energy radius (in arcseconds)
       for distance d (in arcminutes) from the boresight axis
       for a point source of 1.5 keV on the MOS detector"""
    return 28.61381197992193 -  7.917135865709901 * d + (5.290485745213079 + 1.6205710004634912 * d) * log(47.6667 + 39.94444166666666 * d)

def mos5(d):
    """Returns XMM's 90% encircling energy radius (in arcseconds)
       for distance d (in arcminutes) from the boresight adis
       for a point source of 5 keV on the MOS detector"""
    return -7471.449668276366 -  6324.677785146672 * d + 3.89988429779949 * d**2 + (-80.31135326312163 - 894.8657491650612 * d) * log(47.6667 + 39.94444166666666 * d) +  (5792.36526696159 + 6360.1796030529895 * d) * log(log(47.6667 + 39.94444166666666 * d)) 

def mos9(d):
    """Returns XMM's 90% encircling energy radius (in arcseconds)
       for distance d (in arcminutes) from the boresight axis
       for a point source of 9 keV on the MOS detector"""
    return 70.25687576209097 + 16.672833325598635 * d + 0.32696358995439484 * d**2 + (-6.3404116283120855 - 2.30587979355479 * d) * log(47.6667 + 39.94444166666666 * d)

def mos_eer90(e,d):
    """Returns XMM's 90% encircling energy radius (in arcseconds)
       for distance d (in arcminutes) from the boresight axis
       for a point source with energy e (in keV) on the MOS detector"""
    # Interpolate the various 90% encircling energy radii
    if (0 <= d <= 12) :
	    if (e <= 1.5) : return mos1_5(d)
	    elif (1.5 <= e <= 5.) : return mos1_5(d) * (e - 5.) / (1.5 - 5.) + mos5(d) * (e - 1.5) / (5 - 1.5)
	    elif (5. <= e <= 9.) : return mos5(d) * (e - 9.) / (5 - 9.) + mos9(d) * (e - 5.) / (9 - 5.)                 
	    else : return mos9(d)
    else :
	    return -1.

# PNS detector

def pns1_5(d):
    """Returns XMM's 90% encircling energy radius (in arcseconds)
       for distance d (in arcminutes) from the boresight axis
       for a point source of 1.5 keV on the PNS detector"""
    return 24.0892 - 14.887 * d - 0.832074 * d**2 + (6.89861 + 2.7349 * d + 0.1013 * d**2) * log(52.83 + 39.4975 * d)

def pns5(d):
    """Returns XMM's 90% encircling energy radius (in arcseconds)
       for distance d (in arcminutes) from the boresight axis
       for a point source of 5 keV on the PNS detector"""
    return 90.8427 + 25.7445 * d + 1.63039 * d**2 + (-9.66506 - 4.36219 * d - 0.185586 * d**2) * log(52.83 + 39.4975 * d)

def pns9(d):
    """Returns XMM's 90% encircling energy radius (in arcseconds)
       for distance d (in arcminutes) from the boresight axis
       for a point source of 9 keV on the PNS detector"""
    return 238.612 + 123.778 * d + 8.5557 * d**2 + (-46.7187 - 21.953 * d - 1.01651 * d**2) * log(52.83 + 39.4975 * d)

def pns_eer90(e,d):
    """Returns XMM's 90% encircling energy radius (in arcseconds)
       for distance d (in arcminutes) from the boresight axis
       for a point source with energy e (in keV) on the PNS detector"""
    # Interpolate the various 90% encircling energy radii
    if (0 <= d <= 12) :
	    if (e <= 1.5) : return pns1_5(d)
	    elif (1.5 <= e <= 5.) : return pns1_5(d) * (e - 5.) / (1.5 - 5.) + pns5(d) * (e - 1.5) / (5 - 1.5)
	    elif (5. <= e <= 9.) : return pns5(d) * (e - 9.) / (5 - 9.) + pns9(d) * (e - 5.) / (9. - 5.)
	    else : return pns9(d)
    else :
	    return -1.

# Compute Distance from a FITS file
def fits_dist(ra, dec, ra_nom, dec_nom):
    """Takes RA/DEC coordinates in degrees, along with an XMM fits file
       returns the distance from the boresight axis in arcminutes"""
    return 10800. / pi * Vincenty((pi/180.*ra,pi/180.*dec),(pi/180.*ra_nom,pi/180.*dec_nom))
