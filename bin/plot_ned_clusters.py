#!/usr/bin/env python

import sys, csv
from numpy import max, pi
from ephem import Galactic
from plot_clusters import plot_clusters

def uniq(seq):
	"""Uniquifies a list; taken from shootout here:
		http://www.peterbe.com/plog/uniqifiers-benchmark"""
	seen = set()
	seen_add = seen.add
	return [ x for x in seq if x not in seen and not seen_add(x)]


def ned_parse(fp):
	"""A simple parser for a "galaxy_clusters_according_to_ned.txt" TSV file"""
	raw = csv.reader(fp, delimiter="\t",)
	for ln in raw:
		# Grab the size
		sz = int(ln[0])

		# Compute the Galactic coordinates
		coords = ln[1].strip().split('/')[0].replace('_',':')
		try : slon,slat = coords.replace('-',' -').split()
		except ValueError: slon,slat = coords.replace('+',' +').split()
		gal = Galactic(slon,slat)
		lon,lat = float(gal.lon), float(gal.lat)

		# Compute the name
		name = " ".join(uniq(ln[2].split()))

		# Recover the lines of text from the ned database
		nedlns = filter(lambda x: x, ln[3].split(';'))
		# For each nedline, recover the column data - the z values
		nedzs = map(lambda x: float(x.split(',')[1]), nedlns)
		# Compute the highest z value
		maxz = max(nedzs)
		yield [lon, lat, sz, name, 1-maxz]

if False:
        cls = mkClusters(sys.argv[1])                            
        if len(sys.argv) == 5: SZ = int(sys.argv[3])             
        elif len(sys.argv) == 4: SZ = int(sys.argv[2])           
        else : raise "Incorrect command line arguments"          
        print "Culling clusters smaller than", SZ, "..."         
        bigguys = filter(lambda x : len(x) > SZ, cls)
        pts = map(lambda x : list(dataToArray(x)[0]) + [len(x),x[0][7],1],bigguys)    
        print "Making Plot..."                                   
        if len(sys.argv) == 5:                                   
                plot_clusters(pts,sys.argv[4],float(SZ),sys.argv[2])
                print "Wrote:",sys.argv[4]                       
        elif len(sys.argv) == 4:                                 
                plot_clusters(pts,sys.argv[3],float(SZ))
                print "Wrote:",sys.argv[3]                       
        else : raise "Incorrect number of command line arguments"

if __name__ == "__main__":
        if len(sys.argv) == 5: SZ = int(sys.argv[3])             
        elif len(sys.argv) == 4: SZ = int(sys.argv[2])           
        else : raise "Incorrect command line arguments"          
	fp = open(sys.argv[1],'r')
        if len(sys.argv) == 5:                                   
                plot_clusters(ned_parse(fp),sys.argv[4],float(SZ),sys.argv[2])
                print "Wrote:",sys.argv[4]                       
        elif len(sys.argv) == 4:                                 
                plot_clusters(ned_parse(fp),sys.argv[3],float(SZ))
                print "Wrote:",sys.argv[3]                       
        else : raise "Incorrect command line arguments"
	fp.close()
