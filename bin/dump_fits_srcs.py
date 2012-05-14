#!/usr/bin/env python

import sys
from cluster_fits_srcs import get_srcs

if __name__ == "__main__":
    srcs = get_srcs(sys.argv[1:])
    for s in srcs:
        print s[0], '\t', s[1]
