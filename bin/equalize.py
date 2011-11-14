#!/usr/bin/env python
import numpy as np

def histeq(im,nbr_bins=256):

   # Get image histogram
   imhist,bins = np.histogram(im.flatten(),nbr_bins,normed=True)
   cdf = imhist.cumsum() #cumulative distribution function
   cdf_fixed = ((np.max(im) - np.min(im)) * (cdf - np.min(cdf)) / np.max(cdf - np.min(cdf))) + np.min(im) #normalize
   cdf_fixed[0] = np.min(im)

   # Use linear interpolation of cdf to find new pixel values
   im2 = np.interp(im.flatten(),bins[:-1],cdf)

   return im2.reshape(im.shape), cdf
