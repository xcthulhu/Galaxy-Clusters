#!/usr/bin/env python
import sys
from find_clusters import mkClusters,writeClusters,dataToArray
from plot_clusters import plot_clusters

	
if __name__ == "__main__":
	print "Computing clusters..."
        cls = mkClusters(sys.argv[2])
	print "Writing Cluster Directories"
	writeClusters(cls)
        print "Culling clusters smaller than", sys.argv[1], "..."
        bigguys = filter(lambda x : len(x) > int(sys.argv[1]), cls)
        pts = map(lambda x : list(dataToArray(x)[0]) + [len(x)],bigguys)
        print "Making Plot..."
        plot_clusters(pts,sys.argv[3],float(sys.argv[1]))
        print "Wrote:",sys.argv[3]

