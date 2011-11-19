#!/usr/bin/env python
from itertools import chain
import numpy as np
import quat
from numpy import dot, cross, transpose, array
from numpy.linalg import solve
from math import sqrt

"Fixed ortho to give out normal vector"
def orth(v0,v1):
    "Transforms v1 into a normal vector orthogonal to v0"
    v0a, v1a = array(v0), array(v1)
    vv = v1a - (dot(v0a,v1a) * v0a)
    return array(vv / sqrt(dot(vv,vv)))

def rot(v0,v1):
    "Returns a rotation matrix which transforms the plane between v0 and v1 to the xy-plane"
    "Fixed mat3 to np.array"
    return np.array([v0, orth(v0,v1), cross(v0,orth(v0,v1))])

def init(S):
    "Returns an initial estimate of the spherical regression as a quaternion"
    (v0,u0),(v1,u1) = S[0],S[1]
    Rv = rot(v0,v1)
    TRu = rot(u0,u1).transpose()
    mat = map(lambda x: list(x), dot(TRu, Rv))
    #print "Rv:", Rv 
    #print "TRu:", TRu 
    #print "dot:", dot(TRu, Rv)
    #print "mat3:", mat3(dot(TRu, Rv))
    print mat
    return quat(t3(dot(TRu,Rv)))"What is this?"

"Tensor works"
def tensor(v):
    "Returns a tensor corresponding to a three-vector"
    x,y,z = v
    return [[0,-z,y],[z,0,-x],[-y,x,0]]

def im(q):
    "Returns the imaginary part of a quaternion as a list"
    return [q.x, q.y, q.z]

def flatten(lol): 
    "Flattens a list of lists"
    return list(chain.from_iterable(lol))

"Looks like it follows the pdf version of your paper"
def refine(S,q):
    "Refines a quaternion q to one closer to the spherical regression for S"
    qvs = [q * quat([0] + list(v)) * q.inverse() for [v,u] in S]
    M = flatten([tensor(im(qv)) for qv in qvs])
    b = flatten([u for [v,u] in S])
    w = solve(dot(transpose(M),M), dot(transpose(M),b))
    qq = quat([0] + list(w/2)).exp() * q
    return qq.normalize()

epsilon = .0000001 # Error margin for iterative algorithm

def sphreg(S):
    "Perform a spherical regression on S by iterating"
    qold = q = init(S)
    qold *= 1/epsilon
    print q, qold
    while (abs(q - qold) >= epsilon):
        qold = q
        q = refine(S,qold)
	print q, qold
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
