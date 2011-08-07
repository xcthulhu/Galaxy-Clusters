#!/usr/bin/env python
import csv,sys
from find_clusters import tsvDist,pairs

# A little script that calculates the angular extent of a cluster 
# from a tsv file containing some listed observations

if __name__ == "__main__":
        data = csv.reader(open(sys.argv[1]), delimiter='\t')
        print max([tsvDist(line1,line2) for line1,line2 in pairs(list(data))])
