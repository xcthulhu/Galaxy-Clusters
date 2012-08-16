#!/usr/bin/env python
import sys
from XMM_eer90 import fits_dist, pns_eer90

if __name__ == "__main__":
    ra = float(sys.argv[1]) # in DEGS
    dec = float(sys.argv[2]) # in DEGS
    e = float(sys.argv[3])
    fits_fn = sys.argv[4]
    print pns_eer90(e,fits_dist(ra,dec,fits_fn))
