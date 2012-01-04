#!/usr/bin/env python
import numpy as np

def histeq(im,nbr_bins=256):
	# Get image histogram
	imhist,bins = np.histogram(im.flatten(),nbr_bins,normed=True)
	cdf = imhist.cumsum() #cumulative distribution function
	cdf_fixed = (cdf - cdf[0]) / (cdf[-1] - cdf[0]) #normalize
	# Use linear interpolation of cdf to find new pixel values
	im2 = np.interp(im.flatten(),bins[:-1],cdf_fixed)

	return im2.reshape(im.shape), cdf_fixed
