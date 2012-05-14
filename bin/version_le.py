#!/usr/bin/env python
import sys

def lexico_le(ls1, ls2):
    if ls1 == ls2 == []:
       return True
    else :
       fst1,rst1 = ls1[0],ls1[1:]
       fst2,rst2 = ls2[0],ls2[1:]
       if fst1 < fst2: return True
       elif fst1 == fst2 : return lexico_le(rst1,rst2)
       else : return False

if __name__ == "__main__":
    num1 = map(int,sys.argv[1].split('.'))
    num2 = map(int,sys.argv[2].split('.'))
    if lexico_le(num1, num2) : sys.exit(0)
    else : sys.exit(1)
