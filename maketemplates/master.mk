BASEDIR=$(realpath $(RAWBASEDIR))

include $(BASEDIR)/maketemplates/python_logic.mk
BIN:=$(BASEDIR)/bin
BIN=$(BASEDIR)/bin

CIAODIR=/usr/local/ciao-4.3/bin
CIAO_INIT=source $(CIAODIR)/ciao.bash -o

SRC_CLSTR_RADIUS=3 #UNITS: Arcminutes
CLSTR_SZ=5 # UNITS: No. of observations
LOWEST_Z=.05 # UNITS: Z-values
HIGHEST_Z=.3 # UNITS: Z-values
