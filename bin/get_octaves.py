#!/usr/bin/env python
import sys

if __name__ == "__main__":
	band = float(sys.argv[1])
	intervals = map(lambda x: map(float, x.split('-')), sys.argv[2:])
	for x,y in filter(lambda x: x[0] <= band <= x[1], intervals):
		print "{0}-{1}".format(x,y)
