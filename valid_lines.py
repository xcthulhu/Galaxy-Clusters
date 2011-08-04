#!/usr/bin/env python
import csv,sys

def isFloat(string):
    try:
        float(string)
        return True
    except ValueError:
        return False

def unique(seq): 
    # not order preserving 
    set = {} 
    map(set.__setitem__, seq, []) 
    return set.keys()

raw_data = csv.reader(open(sys.argv[1]), delimiter='\t')
valid_lines = filter((lambda x : len(x) > 0 and isFloat(x[0])),raw_data)
for line in valid_lines:
	print '\t'.join(line)
