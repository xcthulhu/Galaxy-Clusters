#!/usr/bin/env python
from itertools import chain
import numpy as np
from quat import quat, matToQuat, quatToMat
from numpy import dot, cross, transpose, array
from numpy.linalg import solve
from math import sqrt

def orth(v0,v1):
    "Transforms v1 into a normal vector orthogonal to v0"
    v0a, v1a = array(v0), array(v1)
    vv = v1a - (dot(v0a,v1a) * v0a)
    return array(vv / sqrt(dot(vv,vv)))

def rot(v0,v1):
    "Returns a rotation matrix which transforms the plane between v0 and v1 to the xy-plane"
    return np.array([v0, orth(v0,v1), cross(v0,orth(v0,v1))])

def init(S):
    "Returns an initial estimate of the spherical regression as a quaternion"
    (v0,u0),(v1,u1) = S[0],S[1]
    Rv = rot(v0,v1)
    TRu = rot(u0,u1).transpose()
    return matToQuat(dot(TRu,Rv))
 
def tensor(v):
    "Returns a tensor corresponding to a three-vector"
    x,y,z = v
    return np.array([[0,-z,y],[z,0,-x],[-y,x,0]])

def flatten(lol): 
    "Flattens a list of lists"
    return list(chain.from_iterable(lol))

def refine(S,q):
    "Refines a quaternion q to one closer to the spherical regression for S"
    # See section 3.2.1 of the paper
    S_ = [[q.rot(v),u] for [v,u] in S]
    M = flatten([-tensor(v) for [v,_] in S_])
    b = flatten([u-v for [v,u] in S_])
    w = solve(dot(transpose(M),M), dot(transpose(M),b))
    qq = quat(1,*(w/2)).normalize()
    return qq

epsilon = .0000001 # Error margin for iterative algorithm

def sphreg(S):
    "Perform a spherical regression on S by iterating"
    qold = q = init(S)
    qold *= 1/epsilon
    #print q, qold
    i = 0
    while (abs(q - qold) >= epsilon):
        qold = q
        q = refine(S,qold)
        #i += 1
        #print i
    return q

# test data
S = [[[0.600884, -0.189253, -0.776609], [-0.608323, 0.629988, 
   0.482761]], [[0.843096, -0.44196, -0.306368], [-0.17129, 0.950487, 
   0.259296]], [[0.690593, -0.0246992, -0.722822], [-0.492167, 
   0.594999, 
   0.635412]], [[0.943338, -0.17462, -0.282173], [-0.0534765, 
   0.861532, 0.50488]], [[0.94118, -0.105895, -0.320885], [-0.0724144,
    0.819294, 
   0.568783]], [[0.700552, -0.565546, -0.435183], [-0.360819, 
   0.922843, 
   0.134796]], [[0.594242, -0.408594, -0.692769], [-0.588393, 
   0.756395, 
   0.285764]], [[0.946455, -0.251276, -0.202691], [0.00154904, 
   0.907207, 0.420682]], [[0.43761, -0.185956, -0.879726], [-0.747074,
    0.505935, 
   0.431174]], [[0.677497, -0.0625201, -0.732864], [-0.51469, 
   0.608795, 0.603708]]]
