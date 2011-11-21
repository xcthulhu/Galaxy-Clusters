#!/usr/bin/env python
import sys, errno
import numpy as np
import matplotlib.pyplot as plt
from correspondents import correspondents, get_points
from sphreg_diagnostics import make_test_image
from scipy.ndimage.interpolation import shift, rotate
from pylab import Arrow

if __name__ == '__main__':
   if len(sys.argv) < 10:
      print >>sys.stderr, "Usage: %s x-dimension y-dimension frequency x-translation y-translation rotation-degrees thresh decimation output_file" % sys.argv[0]
      sys.exit(errno.EINVAL)
   shape = (int(sys.argv[1]),int(sys.argv[2]))
   trans = (int(sys.argv[4]),int(sys.argv[5]))
   theta = float(sys.argv[6])

   # Simulation
   m = make_test_image(shape,float(sys.argv[3]))
   mtr = rotate(shift(m,trans), theta)

   # Plot Image
   fig = plt.figure()
   ax = fig.add_subplot(111,axisbg='k',aspect='equal')
   ax.set_yticks([])
   ax.set_xticks([])
   plt.xlim(0,int(sys.argv[1]))
   plt.ylim(0,int(sys.argv[2]))
   for (x,y) in get_points(m):
	   ax.scatter(x,y,c='y',marker=(5,1),s=100)
   plt.savefig(sys.argv[9])
   for (x,y) in get_points(mtr):
	   ax.scatter(x,y,c='r',marker=(5,1),s=100)
   plt.savefig("with-adjusted-" + sys.argv[9])
   for (x0,y0),(x1,y1) in correspondents(m,mtr,thresh=float(sys.argv[7]),ndigits=int(sys.argv[8])):
	ax.add_patch(Arrow(x0,y0,x1-x0,y1-y0,color='w',linewidth=5,alpha=.25))
   plt.savefig("with-arrows-" + sys.argv[9])
