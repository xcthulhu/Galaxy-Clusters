#!/usr/bin/env python

from random import uniform
from quat import quat
from math import pi
import sys

def random_quat():
    return quat(1, uniform(0,2 * pi),
                   uniform(0,2 * pi),
                   uniform(0,2 * pi)).normalize()

if __name__ == "__main__":
    try: trials = int(sys.argv[1])
    except: trials = 15
    print "Generating", trials, "random quaternion(s):"
    for i in range(trials):
      print random_quat()
