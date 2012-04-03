#!/usr/bin/env python

import sys,pyfits
from equalize import histeq
from kapteyn import maputils
from matplotlib import pyplot as plt
#from scipy.ndimage.filters import gaussian_filter
import warnings

warnings.simplefilter("ignore",DeprecationWarning)

if __name__ == "__main__":
   HST_img = pyfits.open(sys.argv[1])
   HST_hdr = HST_img['PRIMARY'].header
   data,_ = histeq(HST_img['PRIMARY'].data)
   f = maputils.FITSimage(externalheader=HST_hdr,externaldata=data)
   mplim = f.Annotatedimage(cmap="bone")
   mplim.Image()
   mplim.Graticule()
   mplim.plot()
   plt.savefig(sys.argv[2],dpi=300)
   HST_img.close()
