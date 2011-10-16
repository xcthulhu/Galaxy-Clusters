#!/usr/bin/env python
import sys,os.path
from find_clusters import mkClusters,writeClusters,dataToArray
from plot_clusters import plot_clusters

	
if __name__ == "__main__":
	print "Computing clusters..."
        cls = mkClusters(sys.argv[1])
	clsDir = sys.argv[2]
	print ("Writing cluster directories to %s" % clsDir)
	writeClusters(cls,clsDir)
