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
        #print ("Culling clusters smaller than %s..." % sys.argv[1])
        #bigguys = filter(lambda x : len(x) > int(sys.argv[1]), cls)
        #pts = map(lambda x : list(dataToArray(x)[0]) + [len(x),x[0][7]],bigguys)
        #print ("Plotting to %s..." % sys.argv[3])
        #plot_clusters(pts,sys.argv[3],float(sys.argv[1]))
        #print "Wrote:",sys.argv[3]

