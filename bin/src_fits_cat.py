#!/usr/bin/env python

import pyfits
import sys

if __name__ == "__main__":
    hduls = pyfits.open(sys.argv[1])
    print hduls[1].data
    hduls.close()
