include $(RAWBASEDIR)/maketemplates/master.mk
RADIUS=$(shell $(PYTHON) $(BASEDIR)/bin/get_master_radius.py)

# Determine the lattitude and longitude from the directory path name
LAT=$(shell echo $(notdir $(shell pwd)) | sed -e 's/+/X/' -e 's/-/X/' -e 's/_/:/g' | cut -d 'X' -f 1 )
LON=$(shell echo $(notdir $(shell pwd)) | sed -e 's/+/X/' -e 's/-/X/' -e 's/_/:/g' | cut -d 'X' -f 2 )

all : hubble-obs_R$(RADIUS).csv FITS/Makefile Images/Makefile
	$(MAKE) -C FITS all

%.csv : 
	$(PYTHON) $(BIN)/get_HST_obs.py $(LAT) $(LON) $(shell echo $@ | cut -d '_' -f 2 | sed -e 's/R//' -e 's/.csv//' ) > $@

FITS :
	[ -d $@ ] || mkdir $@
	touch $@

FITS/Makefile : hubble-obs_R$(RADIUS).csv
	$(MAKE) FITS
	echo RAWBASEDIR=$(RAWBASEDIR)/.. > $@
	echo WFPC="$(patsubst %, %_c0f.fits, $(shell grep WFPC hubble-obs_R$(RADIUS).csv | grep -v WFPC2 | cut -d ',' -f 1))" >> $@
	echo WFPC2="$(patsubst %, %_DRZ.fits, $(shell grep WFPC2 hubble-obs_R$(RADIUS).csv | cut -d ',' -f 1))" >> $@
	echo WFC3="$(patsubst %, %_DRZ.fits, $(shell grep WFC3 hubble-obs_R$(RADIUS).csv | cut -d ',' -f 1))" >> $@
	echo ACS="$(patsubst %, %_DRZ.fits, $(shell grep ACS hubble-obs_R$(RADIUS).csv | cut -d ',' -f 1))" >> $@
	echo include '$$(RAWBASEDIR)'/maketemplates/HST_FITS.mk >> $@

Images :
	[ -d $@ ] || mkdir $@
	touch $@

Images/Makefile : 
	$(MAKE) Images
	echo RAWBASEDIR=$(RAWBASEDIR)/.. > $@
	echo include '$$(RAWBASEDIR)'/maketemplates/HST_Images.mk >> $@

clean :
	rm -rf Images *.csv
