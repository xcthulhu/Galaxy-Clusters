#!/usr/bin/env python
import sys
import os
import errno
import numpy as np

def mkdir_p(path):
    try: os.makedirs(path)
    except OSError as exc: 
        if exc.errno == errno.EEXIST: pass
        else: raise

if __name__ == "__main__" : 
   parent_dir = sys.argv[1]
   data = np.loadtxt(sys.argv[2])
   bands = map(float,sys.argv[3].split())
   octaves = map(lambda x : map(float, x.split('-')),sys.argv[4].split())
   # For speed purposes, we only care about the middle bands
   middle_bands = [ (j+k)/2. for j,k in octaves ] 
   for ln in data:
      ra,dec = ln[0:2]
      r = dict(zip(bands,ln[2:]))
      for band in middle_bands:
         dir = os.path.join(parent_dir,
                            "{0}_{1}_{2}_{3}".format(ra, dec, r[band], band))
  	 mkdir_p(dir)
