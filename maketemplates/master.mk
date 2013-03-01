BASEDIR=$(realpath $(RAWBASEDIR))

include $(BASEDIR)/maketemplates/python_logic.mk
BIN=$(BASEDIR)/bin

CIAODIR=$(BASEDIR)/ciao-4.4/bin
#CIAO_INIT=source $(CIAODIR)/ciao.sh -o -q &> /dev/null
CIAO_INIT=source $(CIAODIR)/ciao.sh -o -q &> /dev/null && export PFILES=$${PFILES/*;/$(shell mkdir -p $(CURDIR)/params && env TMPDIR=$(CURDIR)/params mktemp -d);} 
CIAO_VER=$(shell $(CIAO_INIT) && ciaover | head -1 | cut -d' ' -f2)
CHANDRA_REPRO=$(CIAODIR)/../contrib/bin/chandra_repro
CHANDRA_WINDOW_SIZE=2304
CHANDRA_STEP_SIZE=$(shell echo "scale=20; $(CHANDRA_WINDOW_SIZE) / 2" | bc)
CHANDRA_BINNING=$(shell echo "scale=20; $(CHANDRA_WINDOW_SIZE) / 576" | bc)

SOURCE_CLSTR_ARCSECS=3 # UNITS: Arseconds
CLSTR_SZ=5 # UNITS: No. of observations
LOWEST_Z=.05 # UNITS: Z-values
HIGHEST_Z=.3 # UNITS: Z-values

# Band intervals in eV
BOT=200
B1END=500
B2END=1000
B3END=2000
B4END=4500
TOP=12000
BANDS=$(BOT) $(shell echo "scale=2; ($(BOT) + $(B1END)) / 2" | bc) $(B1END) $(shell echo "scale=2; ($(B1END) + $(B2END)) / 2" | bc) $(B2END) $(shell echo "scale=2; ($(B2END) + $(B3END)) / 2" | bc) $(B3END) $(shell echo "scale=2; ($(B3END) + $(B4END)) / 2" | bc) $(B4END) $(shell echo "scale=2; ($(B4END) + $(TOP)) / 2" | bc) $(TOP)

# Named Bands
B1=$(BOT)-$(B1END)
B2=$(B1END)-$(B2END)
B3=$(B2END)-$(B3END)
B4=$(B3END)-$(B4END)
B5=$(B4END)-$(TOP)

OCTAVES=$(B1) $(B2) $(B3) $(B4) $(B5) 
