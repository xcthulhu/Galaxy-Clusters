#!/usr/bin/env python
from mpl_toolkits.basemap import Basemap
import numpy as np
import matplotlib.pyplot as plt
import sys
from math import log,pi
from find_clusters import mkClusters,dataToArray

import find_clusters # Module in this directory

def r2d(r) : return r / (2*pi) * 360

def plot_clusters(pts,filename,scale):
	m = Basemap(projection='moll',lon_0=0,resolution='c')
	m.drawparallels(np.arange(-90.,120.,15.),color='white',linewidth=.5)
	m.drawmeridians(np.arange(0.,420.,15.),color='white',linewidth=.5)
	m.drawmapboundary(fill_color='black')
	for px,py,sz,name in pts:
		x,y = m(r2d(px),r2d(py))
		plt.plot(x,y,'*',color='yellow',markersize=scale*log(sz,scale))
		plt.text(x,y,name,color='red',size=2)
	#plt.title("Galaxy Clusters")
	plt.savefig(filename)

if __name__ == "__main__":
	print "Computing cluster points..."
	cls = mkClusters(sys.argv[2])
	print "Culling clusters smaller than", sys.argv[1], "..."
	bigguys = filter(lambda x : len(x) > int(sys.argv[1]), cls)
	pts = map(lambda x : list(dataToArray(x)[0]) + [len(x),x[0][7]],bigguys)
	print "Making Plot..."
	plot_clusters(pts,sys.argv[3],float(sys.argv[1]))
	print "Wrote:",sys.argv[3]
