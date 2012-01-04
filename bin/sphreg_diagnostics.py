#!/usr/bin/env python
import numpy as np
import sphreg as sph
from random import uniform

def normalize(v):
  """Normalizes a vector"""
  return np.array(v) / np.sqrt(np.dot(v,v))

def vector_gen(N):
  """Generates a Nx3 matrix containing N random normalized vectors"""
  return np.array([normalize([uniform(0,1),uniform(0,1),uniform(0,1)])
	           for i in range(N)])

def random_rot():
  """random_rot()
  - Returns a random rotation matrix"""
  r = np.zeros((3,3),dtype=np.float)
  return sph.gramm(np.vectorize(lambda x: uniform(0,1))(r))

def make_test_image(shape, freq):
  """make_test_image(shape, frequency)
  - Outputs: A binary numpy array m where m.shape == shape and
 
  (# of non-zero points)
  ---------------------   == freq
      total points
	  
  the points are uniformly distributed"""
  def maybe(x) : 
      if uniform(0,1) < freq : return 1
      else : return 0
  m = np.zeros(shape)
  return np.vectorize(maybe)(m)
