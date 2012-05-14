#!/usr/bin/env python
import sys
import csv
from functools import partial

def est_energy(target_energy_percentage, filename):
    f = open(filename, 'r')

    data = list(csv.reader(f, delimiter=' '))
    for i in range(1,len(data)):
        this_energy_percentage = float(data[i][-1])
        if this_energy_percentage >= target_energy_percentage:
            old_energy_percentage = float(data[i-1][-1])
            old_rad = float(data[i-1][-2])
            this_rad = float(data[i][-2])
            # Assume energy increases linearly with radius between the two observations
            # Compute rise and run
            dE = this_energy_percentage - old_energy_percentage
            dR = this_rad - old_rad
            # We can solve for the radius of the target energy, 
            # which gives the following equation:
            f.close()
            return "%s\t%f" % (filename,
                               old_rad + dR/dE * (target_energy_percentage -
                                                  old_energy_percentage))

if __name__ == "__main__":
    target_energy_percentage = float(sys.argv[1])/100.
    
    for filename in sys.argv[2:]:
        print est_energy(target_energy_percentage, filename)
