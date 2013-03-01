#!/usr/bin/env python

import pyfits
import sys

if __name__ == "__main__":
	f = pyfits.open(sys.argv[1])
	count = len(f['EVENTS'].data)
	f.close()
	if count == 0 : sys.exit(1)
	else : sys.exit()
