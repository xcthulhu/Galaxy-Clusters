#!/usr/bin/env python
import re, fileinput, sys

# This script takes as input:
#   - the output from the dmlist command (either as a file or a stream) 
# and outputs: 
#   - a tab seperated value file to stdout

if __name__ == "__main__":

	# A header describing the columns of the output
	#header=["time","ccd_id","node_id","expno","chipx","chipy","tdetx","tdety","detx","dety","skyx","skyy","pha","pha_ro","energy","pi","fltgrade","grade","status","RA","DEC"]
	#print "\t".join(header)

	parse = re.compile("\W*(\d+)\W+([\d\.]+)\W+(\d+)\W+(\d+)\W+(\d+)\W+\((\d+),(\d+)\)\W+\((\d+),(\d+)\)\W+\(\W+([\d\.]+),\W+([\d\.]+)\)\W+\(\W+([\d\.]+),\W+([\d\.]+)\)\W+(\d+)\W+(\d+)\W+([\d\.]+)\W+(\d+)\W+(\d+)\W+(\d+)\W+(\d+)\W+\(\W+([\d\.]+),\W+([\d\.]+)\)")

	for line in fileinput.input():
		try : print "\t".join(map(lambda x: parse.match(line).group(x), range(2,23)))
		except : print >> sys.stderr, "Could not parse", line
