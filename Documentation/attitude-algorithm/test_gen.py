import numpy as np
import random
from math import sqrt
from random import uniform
from math import pi

def vector_gen(N):
  "Generates a Nx3 matrix containing N random normalized vectors"
  test_vector_acc = np.zeros((N,3))
  for x in range(0,N):
	test_vector_acc[x] = rand_num_gen()
  return test_vector_acc

def normalize(v) :
	return v / np.sqrt(np.dot(v,v))

def vector_cluster_gen(n,var = 0.01):
  test_vector = vector_gen(1)[0]
  vector_cluster = np.zeros((n,3))
  for i in range(n):  
    nudge = np.array([uniform(-var,var),uniform(-var,var),uniform(-var,var)])
    vector_cluster[i] = normalize(test_vector + nudge)
  return vector_cluster
    

def rand_num_gen():
  "Generates a 1x3 random normalized vector"
  ar1 = np.array([random.randrange(-100,100,1),random.randrange(-100,100,1),random.randrange(-100,100,1)])
  return ar1/np.sqrt(np.dot(ar1,ar1))

 
def gramm(X,inplace = False):
    "Returns the Gramm-Schmidt orthogonalization of matrix X"
    if not inplace:
       V = [row[:] for row in X] 
    else:
       V = X
    k = len(X[0])           
    n = len(X)             
 
    for j in range(k):
       for i in range(j):
          
          D = sum([V[p][i]*V[p][j] for p in range(n)])
 
          for p in range(n): 
            V[p][j] -= (D * V[p][i])
 
       
       invnorm = 1.0 / sqrt(sum([(V[p][j])**2 for p in range(n)]))
       for p in range(n):
           V[p][j] *= invnorm
    return V
