#!/usr/bin/env python
import re, fileinput, sys

# This script takes as input:
#   - the output from the dmlist command (either as a file or a stream) 
# and outputs: 
#   - a tab seperated value file to stdout

if __name__ == "__main__":

	# A header describing the columns of the output
	header=["#","time","energy","skyx","skyy","RA","DEC"]
	print "\t".join(header)

	for line in fileinput.input():
		l1 = re.sub("[(),]"," ",line)
		print re.sub("[ ]+","\t",l1).strip()
