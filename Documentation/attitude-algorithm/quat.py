#!/usr/bin/env python
from numbers import *
from numpy import sqrt, dot, array
from types import *

# Comparison threshold
_epsilon = 1E-12

class quat:
    def __init__(self,w=0,x=0,y=0,z=0):
        self.q = array([float(w),float(x),
                        float(y),float(z)])

    def __str__(self):
        "Yields quaternion as string for printing"
        return "%g + i%g + j%g + k%g" % tuple(self.q)
    
    def __repr__(self):
        "Representation of the quaternion for debugging"
        return str(self)

    def __add__(self,ob):
        "Addition operation for quaternions"
        if any([isinstance(ob,FloatType),
                isinstance(ob,IntType),
                isinstance(ob,LongType)]):
            return quat(self.q[0] + ob, *(self.q[1:]))
        else: return quat(*(self.q + ob.q))

    def __sub__(self,ob):
        "Subtraction operation for quaternions"
        if any([isinstance(ob,FloatType),
                isinstance(ob,IntType),
                isinstance(ob,LongType)]):
            return quat(self.q[0] - ob, *(self.q[1:]))
        else: return quat(*(self.q - ob.q))

    def __mul__(self,ob):
        "Product operation for quaternions"
        if any([isinstance(ob,FloatType),
                isinstance(ob,IntType),
                isinstance(ob,LongType)]):
            return quat(*(self.q*ob))
        else: return quat(
            self.q[0]*ob.q[0] - self.q[1]*ob.q[1] - self.q[2]*ob.q[2] - self.q[3]*ob.q[3],
            self.q[1]*ob.q[0] + self.q[0]*ob.q[1] - self.q[3]*ob.q[2] + self.q[2]*ob.q[3], 
            self.q[2]*ob.q[0] + self.q[3]*ob.q[1] + self.q[0]*ob.q[2] - self.q[1]*ob.q[3],
            self.q[3]*ob.q[0] - self.q[2]*ob.q[1] + self.q[1]*ob.q[2] + self.q[0]*ob.q[3])

    def conjugate(self):
        "Quaternion conjugation"
        return quat(self.q[0],-self.q[1],-self.q[2],-self.q[3])

    def norm2(self):
        "Yields the square of the norm of a quaternion"
        return dot(self.q,self.q)

    def __abs__(self):
        "Yields the norm of a quaternion"
        return sqrt(self.norm2())
 
    def normalize(self):
        "Normalizes a quaternion"
        return self / abs(self)

    def __div__(self,ob):
        "Division for quaternions"
        if any([isinstance(ob,FloatType),
                isinstance(ob,IntType),
                isinstance(ob,LongType)]):
            return quat(*(self.q / ob))
        else: return self * ob.conjugate() / ob.norm2()

    def rot(self,vect):
        "Rotates a vector or a vector defined as a quaternion 0+xi+yj+zk with respect to the quaternion"
        try : return (self*quat(0,*vect)/self).q[1:]
	except : return self*vect/self

def AxisAngleToQuat(theta,v):
    "Yields a quaternion from axis-angle representation of a rotation"
    sn = sin(theta/2.0)
    return quat(cos(theta/2.0),v[0]*sn,v[1]*sn,v[2]*sn).normalize()

def MatToQuat(m):
    "Converts a rotation matrix to a quaternion"
    tr=m[0][0]+m[1][1]+m[2][2]
    if tr > _epsilon:
        w2=sqrt(1+tr)
        return quat(w2/2,
                    (m[2][1]-m[1][2])/(2*w2),
                    (m[0][2]-m[2][0])/(2*w2),
                    (m[1][0]-m[0][1])/(2*w2)).normalize()
    else:
        x2=sqrt(max(0,1+m[0][0]-m[1][1]-m[2][2]))
        y2=sqrt(max(0,1+m[1][1]-m[2][2]-m[0][0]))
        z2=sqrt(max(0,1+m[2][2]-m[0][0]-m[1][1]))
        if (x2 > y2) and (x2 > z2):
           return quat((m[2][1]-m[1][2])/(2*x2),
                       x2/2,
                       (m[1][0]+m[0][1])/(2*x2),
                       (m[0][2]+m[2][0])/(2*x2)).normalize()
        elif (y2 > z2):
           return quat((m[0][2]-m[2][0])/(1*y2),
                       (m[1][0]+m[0][1])/(2*y2),
                       y2/2,
                       (m[2][1]+m[1][2])/(2*y2)).normalize()
        else:
           return quat((m[1][0]-m[0][1])/(2*z2),
                       (m[0][2]+m[2][0])/(2*z2),
                       (m[2][1]+m[1][2])/(2*z2),
                       z2/2).normalize()


