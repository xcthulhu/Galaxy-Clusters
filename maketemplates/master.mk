BASEDIR=$(realpath $(RAWBASEDIR))

include $(BASEDIR)/maketemplates/python_logic.mk
BIN:=$(BASEDIR)/bin
BIN=$(BASEDIR)/bin

ifeq ("$(shell sw_vers | grep 'ProductVersion:' | grep -o '[0-9]*\.[0-9]*\.[0-9]*' | cut -d'.' -f1,2)", "10.6")
  CIAODIR=$(BASEDIR)/ciao-4.4/bin
else
  CIAODIR=/usr/local/ciao-4.3/bin
endif

CIAO_INIT=source $(CIAODIR)/ciao.bash -o

CIAO_VER=$(shell $(CIAO_INIT) &> /dev/null && ciaover | head -1 | cut -d' ' -f2)

SRC_CLSTR_RADIUS=3 #UNITS: Arcminutes
CLSTR_SZ=5 # UNITS: No. of observations
LOWEST_Z=.05 # UNITS: Z-values
HIGHEST_Z=.3 # UNITS: Z-values
