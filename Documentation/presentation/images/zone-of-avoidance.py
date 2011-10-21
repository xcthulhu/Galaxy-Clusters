#!/usr/bin/env python
from matplotlib import rc
from mpl_toolkits.basemap import Basemap
from master_variables import ZONE_OF_AVOIDANCE
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
	m.drawparallels([ZONE_OF_AVOIDANCE,-ZONE_OF_AVOIDANCE],color='r',linewidth=1)
	m.warpimage(sys.argv[1],scale=1.0)
	#m.drawgreatcircle(0,0,4*15,0,color='r',linewidth=1)
	x,y=m(0,-(ZONE_OF_AVOIDANCE+2))
	plt.text(x,y,r'$b = %i^{\circ}$' % (-(ZONE_OF_AVOIDANCE)),color='r',size=7, ha='center', va='top')
	x_,y_=m(0,(ZONE_OF_AVOIDANCE+2))
	plt.text(x_,y_,r'$b = %i^{\circ}$' % (ZONE_OF_AVOIDANCE),color='r',size=7,ha='center', va='bottom')
	x__,y__=m(0,0)
	plt.text(x__,y__,r'Zone of Avoidance',color='r',size=16,ha='center', va='center')
	# Draw a line of latitude
	#m.drawgreatcircle(4*15,0,4*15,4*15,color='r',linewidth=1)
	#x_,y_=m(4*15+4,2*15)
	#plt.text(x_,y_,r'$b$',color='r',size=16)
	plt.savefig(sys.argv[2],dpi=300,transparent=True)
