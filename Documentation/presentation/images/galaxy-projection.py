#!/usr/bin/env python
from matplotlib import rc
from mpl_toolkits.basemap import Basemap
import numpy as np
import matplotlib.pyplot as plt
import sys

if __name__ == "__main__":
	rc('text', usetex=True)
	rc('font', family='serif')
	# lon_0 is central longitude of projection.
	# resolution = 'c' means use crude resolution coastlines.
	m = Basemap(projection='moll',lat_0=0,lon_0=0,resolution='h')
	# draw parallels and meridians.
	m.drawparallels(np.arange(-90.,180.,15.),color='white',linewidth=.5)
	m.drawmeridians(np.arange(0.,420.,15.),color='white',linewidth=.5)
	# Draw a line of longitude
	m.drawgreatcircle(0,0,4*15,0,color='r',linewidth=1)
	x,y=m(4*7.5,-10)
	plt.text(x,y,r'$\ell$',color='r',size=16)
	# Draw a line of latitude
	m.drawgreatcircle(4*15,0,4*15,4*15,color='r',linewidth=1)
	x_,y_=m(4*15+4,2*15)
	plt.text(x_,y_,r'$b$',color='r',size=16)
	m.warpimage(sys.argv[1],scale=1.0)
	plt.savefig(sys.argv[2],dpi=300)
