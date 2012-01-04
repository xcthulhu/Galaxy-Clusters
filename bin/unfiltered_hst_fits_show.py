#!/usr/bin/env python

import sys,pyfits
from equalize import hst_bg_fix
from kapteyn import maputils
from matplotlib import pyplot as plt
from scipy.ndimage.filters import gaussian_filter
import warnings

warnings.simplefilter("ignore",DeprecationWarning)

if __name__ == "__main__":
   HST_img = pyfits.open(sys.argv[1])
   data = hst_bg_fix(HST_img[1].data)
   f = maputils.FITSimage(externalheader=HST_img[1].header,externaldata=data)
   mplim = f.Annotatedimage(cmap="bone")
   mplim.Image()
   mplim.Graticule()
   mplim.plot()
   plt.savefig(sys.argv[2])
   HST_img.close()
