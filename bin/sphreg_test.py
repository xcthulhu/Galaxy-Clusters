#!/usr/bin/env python
import numpy as np
import sphreg as sph
import sys
from random import uniform

def normalize(v):
  """Normalizes a vector"""
  return np.array(v) / np.sqrt(np.dot(v,v))

def vector_gen(N):
  """Generates a Nx3 matrix containing N random normalized vectors"""
  return np.array([normalize([uniform(0,1),uniform(0,1),uniform(0,1)])
	           for i in range(N)])

def random_rot():
  "Returns a random rotation matrix"
  r = np.zeros((3,3),dtype=np.float)
  return sph.gramm(np.vectorize(lambda x: uniform(0,1))(r))
