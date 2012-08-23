include $(RAWBASEDIR)/maketemplates/master.mk

# GZipped Satellite Attitude file
GZATT=$(wildcard ../pps/*ATT*.FTZ)

# We guard against event files not existing ; we also don't bother to do anything if 
# we can't figure out the satellite's attitude
EVT_FILES=$(wildcard MOS*MIEVL*.FIT PN*MIEVL*.FIT)
LIGHT_CURVES = $(EVT_FILES:.FIT=_lightc.fits)
GTI_FILES = $(EVT_FILES:.FIT=_gti.fits)
FILT_EVT_FILES = $(EVT_FILES:.FIT=_filt.fits)
DS9_IMG_FILES = $(EVT_FILES:.FIT=_ds9_img.fits)
DS9_IMG_PDFS = $(EVT_FILES:.FIT=_ds9_img.pdf)

# Determine the ranges for various bands
BOT=200
B1END=500
B2END=1000
B3END=2000
B4END=4500
TOP=12000

# From the eventfiles, we generate other files names, which describe bandpasses we will perform
B1_NAME=$(EVT_FILES:.FIT=b1_$(BOT)_$(B1END)_green_band_img.fits)
B2_NAME=$(EVT_FILES:.FIT=_b2_$(B1END)_$(B2END)_red_band_img.fits)
B3_NAME=$(EVT_FILES:.FIT=_b3_$(B2END)_$(B3END)_blue_band_img.fits)
B4_NAME=$(EVT_FILES:.FIT=_b4_$(B3END)_$(B4END)_magenta_band_img.fits)
B5_NAME=$(EVT_FILES:.FIT=_b5_$(B4END)_$(TOP)_cyan_band_img.fits)
FULL_NAME=$(EVT_FILES:.FIT=_full_$(BOT)_$(TOP)_white_band_img.fits)
ALL_NAMES=$(B1_NAME) $(B2_NAME) $(B3_NAME) $(B4_NAME) $(B5_NAME) $(FULL_NAME)

SOURCES=$(EVT_FILES:.FIT=_emllist.fits)

ifneq ($(SOURCES),)
SOURCES_TXT=sources.txt
SOURCES_COORDS=$(shell test -e sources.txt && sed -e 's/ \t/_/g' sources.txt)
endif

SOURCE_EVT_BKGS_PIS=$(patsubst sources/bkgs/%_bkg_evts.fits, sources/PI/%_bkg_evts_pi.fits, $(SOURCE_EVT_BKGS))

.SECONDARY : 
.PHONY: all lightcurves gti source_background_evts 

all : ccf.cif emchain epchain $(ALL_BANDS) $(ALL_NAMES) $(SOURCES_TXT) $(FILT_EVT_FILES)

emchain epchain : ccf.cif ../odf/odfingest
	. $(BIN)/XMM_common.sh && $@ &> $@

evil :
	@for i in $(wildcard P[0-9]*M1*MIEVL*.FIT) ; do \
		echo rm -f MOS1$$i ; \
		rm -f MOS1$$i ; \
		echo ln -s $$i MOS1$$i ; \
		ln -s $$i MOS1$$i ; \
		true ; \
	done
	@for i in $(wildcard P[0-9]*M2*MIEVL*.FIT) ; do \
		echo rm -f MOS2$$i ; \
		rm -f MOS2$$i ; \
		echo ln -s $$i MOS2$$i ; \
		ln -s $$i MOS2$$i ; \
		true ; \
	done
	@for i in $(wildcard P[0-9]*PN*PIEVL*.FIT) ; do \
		echo rm -f PN$$i ; \
		rm -f PN$$i ; \
		echo ln -s $$i PN$$i ; \
		ln -s $$i PN$$i ; \
		true ; \
	done

test :
	echo $(SOURCES)

lightcurves: $(LIGHT_CURVES)

gti : emchain epchain
	make $(GTI_FILES)

../odf/Makefile : 
	make -C .. odf/Makefile

../odf/untar : ../odf/Makefile
	make -C $(dir $@) $(notdir $@)

ccf.cif : ../odf/untar
	$(BIN)/cifbuild.sh

../odf/odfingest : ../odf/untar ccf.cif
	make -C $(dir $@) $(notdir $@)

attds.fits : $(GZATT)
	cp -f $^ $@

%_ds9_img.pdf : %_ds9_img.fits
	$(BIN)/fits_show.py $< $@

%_ds9_img.fits : %.FIT
	$(BIN)/mk_XMM_image.sh $< $@

# Compute light curves for each detector
MOS%_lightc.fits : MOS%.FIT ccf.cif
	$(BIN)/mos_lightc.sh $< $@

PN%_lightc.fits : PN%.FIT ccf.cif
	$(BIN)/mos_lightc.sh $< $@

MOS%_gti.fits : MOS%_lightc.fits emchain
	$(BIN)/mos_gti.sh $< $@

PN%_gti.fits : PN%_lightc.fits epchain
	$(BIN)/pn_gti.sh $< $@

%_filt.fits : %.fits %_gti.fits
	$(BIN)/XMM_filtered_evt.sh $^ $@

MOS%_band_img.fits: 
	make $(shell echo $@ | sed -e 's/_.*/\.FIT/') $(shell echo $@ | sed -e 's/_.*/_gti\.fits/')
	$(BIN)/mos_get_band.sh $(shell echo $@ | sed -e 's/_.*/\.FIT/') $(shell echo $@ | sed -e 's/_.*/_gti\.fits/') $@ $(shell echo $@ | sed -e 's/_/ /g' | cut -f3,4 -d" ")

PN%_band_img.fits:
	make $(shell echo $@ | sed -e 's/_.*/\.FIT/') $(shell echo $@ | sed -e 's/_.*/_gti\.fits/')
	$(BIN)/pn_get_band.sh $(shell echo $@ | sed -e 's/_.*/\.FIT/') $(shell echo $@ | sed -e 's/_.*/_gti\.fits/') $@ $(shell echo $@ | sed -e 's/_/ /g' | cut -f3,4 -d" ")

%_b1_img.fits: %_b1_$(BOT)_$(B1END)_green_band_img.fits
	ln -sf $< $@

%_b2_img.fits: %_b2_$(B1END)_$(B2END)_red_band_img.fits
	ln -sf $< $@

%_b3_img.fits: %_b3_$(B2END)_$(B3END)_blue_band_img.fits
	ln -sf $< $@

%_b4_img.fits: %_b4_$(B3END)_$(B4END)_magenta_band_img.fits
	ln -sf $< $@

%_b5_img.fits: %_b5_$(B4END)_$(TOP)_cyan_band_img.fits
	ln -sf $< $@

%_full_img.fits: %_full_$(BOT)_$(TOP)_white_band_img.fits
	ln -sf $< $@

MOS1%_emllist.fits: MOS1%.FIT attds.fits MOS1%_b1_img.fits MOS1%_b2_img.fits MOS1%_b3_img.fits MOS1%_b4_img.fits MOS1%_b5_img.fits
	rm -f *$@ *$(shell echo $@ | sed -e 's/MOS1/MOS2/')
	-$(BIN)/MOS1%_source_detect.sh $@ $^

MOS2%_emllist.fits: MOS2%.FIT attds.fits MOS2%_b1_img.fits MOS2%_b2_img.fits MOS2%_b3_img.fits MOS2%_b4_img.fits MOS2%_b5_img.fits
	rm -f *$@ *$(shell echo $@ | sed -e 's/MOS2/MOS1/')
	-$(BIN)/MOS2%_source_detect.sh $@ $^

PN%_emllist.fits: PN%.fits attds.fits PN%_b1_img.fits PN%_b2_img.fits PN%_b3_img.fits PN%_b4_img.fits PN%_b5_img.fits
	rm -f *$@
	$(BIN)/pn_source_detect.sh $@ $^

sources.txt: $(SOURCES)
	$(PYTHON) $(BIN)/dump_XMM_sourcelist.py $^ | uniq > $@

clean :
	rm -f *.txt *.fits ccf.cif *.pdf *.gz *.grp *.FIT *.MOS emchain epchain core* *mos*
