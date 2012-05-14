#!/usr/bin/env python
import pyfits
import os.path
import sys
import numpy as np

def print_sources(filename):
    """Prints the sources in filename to standard out"""
    if os.path.isfile(filename):
        try :
           srcs = pyfits.open(filename)
           for source in srcs['srclist'].data:
              print source['ra'], '\t', source['dec']
           srcs.close()
        except: pass

if __name__ == "__main__":
    map(print_sources,sys.argv[1:])
