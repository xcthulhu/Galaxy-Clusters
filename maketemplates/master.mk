BASEDIR=$(realpath $(RAWBASEDIR))

include $(BASEDIR)/maketemplates/python_logic.mk
BIN:=$(BASEDIR)/bin
BIN=$(BASEDIR)/bin

CIAODIR=$(BASEDIR)/ciao-4.4/bin
CIAO_INIT=source $(CIAODIR)/ciao.sh -o -q
CIAO_VER=$(shell $(CIAO_INIT) &> /dev/null && ciaover | head -1 | cut -d' ' -f2)
CHANDRA_REPRO=$(BASEDIR)/ciao-4.4/contrib/bin/chandra_repro

SRC_CLSTR_RADIUS=3 #UNITS: Arcminutes
CLSTR_SZ=5 # UNITS: No. of observations
LOWEST_Z=.05 # UNITS: Z-values
HIGHEST_Z=.3 # UNITS: Z-values
