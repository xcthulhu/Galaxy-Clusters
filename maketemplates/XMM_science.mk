include $(RAWBASEDIR)/maketemplates/master.mk

# GZipped Satellite Attitude file
GZATT=$(wildcard ../pps/*ATT*.FTZ)

# We guard against event files not existing ; we also don't bother to do anything if 
# we can't figure out the satellite's attitude
LIGHT_CURVES = $(EVL:.FIT=_lightc.fits)
GTI_FILES = $(EVL:.FIT=_gti.fits)
FILT_EVL = $(EVL:.FIT=_filt.fits)
DS9_IMG_FILES = $(EVL:.FIT=_ds9_img.fits)
DS9_IMG_PDFS = $(EVL:.FIT=_ds9_img.pdf)

# Determine the ranges for various bands
BOT=200
B1END=500
B2END=1000
B3END=2000
B4END=4500
TOP=12000

# From the eventfiles, we generate other files names, which describe bandpasses we will perform
B1_BAND=$(EVL:.FIT=_b1_$(BOT)_$(B1END)_green_band_img.fits)
B2_BAND=$(EVL:.FIT=_b2_$(B1END)_$(B2END)_red_band_img.fits)
B3_BAND=$(EVL:.FIT=_b3_$(B2END)_$(B3END)_blue_band_img.fits)
B4_BAND=$(EVL:.FIT=_b4_$(B3END)_$(B4END)_magenta_band_img.fits)
B5_BAND=$(EVL:.FIT=_b5_$(B4END)_$(TOP)_cyan_band_img.fits)
FULL_BAND=$(EVL:.FIT=_full_$(BOT)_$(TOP)_white_band_img.fits)
ALL_BANDS=$(B1_BAND) $(B2_BAND) $(B3_BAND) $(B4_BAND) $(B5_BAND) $(FULL_BAND)

SOURCES=$(EVL:.FIT=_emllist.txt)

.SECONDARY : 
.PHONY: lightcurves gti filter
.DELETE_ON_ERROR: $(SOURCES) source.txt
ifeq ($(GZATT),)
all : sources.txt
sources.txt :
	touch $@

else
all : attds.fits sources.txt

MOS1%.FIT MOS2%.FIT PN%.FIT : ../work/%.FIT ../work/epchain ../work/emchain
	ln -sf $< $@

ccf.cif : ../work/ccf.cif
	ln -s $< $@

../work/ccf.cif ../work/emchain ../work/epchain ../odf/untar ../odf/odfingest: ../work/Makefile ../odf/Makefile
	make -C $(dir $@) $(notdir $@)

../odf/Makefile : 
	make -C .. odf/Makefile

../work/Makefile : 
	make -C .. work/Makefile

attds.fits : $(GZATT)
	cp -f $^ $@

../master_sources.txt : 
	make -C .. master_sources.txt

master_sources.txt : ../master_sources.txt
	ln -s $< $@

# Compute light curves for each detector
MOS%_lightc.fits : MOS%.FIT ccf.cif
	$(BIN)/mos_lightc.sh $< $@

PN%_lightc.fits : PN%.FIT ccf.cif
	$(BIN)/pn_lightc.sh $< $@

MOS%_gti.fits : MOS%_lightc.fits 
	$(BIN)/mos_gti.sh $< $@

PN%_gti.fits : PN%_lightc.fits 
	$(BIN)/pn_gti.sh $< $@

gti : $(GTI_FILES)

filter : $(FILT_EVL)

%_filt.fits : %.FIT %_gti.fits
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
	$(BIN)/MOS1_source_detect.sh $@ $^

MOS2%_emllist.fits: MOS2%.FIT attds.fits MOS2%_b1_img.fits MOS2%_b2_img.fits MOS2%_b3_img.fits MOS2%_b4_img.fits MOS2%_b5_img.fits
	$(BIN)/MOS2_source_detect.sh $@ $^

PN%_emllist.fits: PN%.FIT attds.fits PN%_b1_img.fits PN%_b2_img.fits PN%_b3_img.fits PN%_b4_img.fits PN%_b5_img.fits
	$(BIN)/PN_source_detect.sh $@ $^

%_emllist.txt: %_emllist.fits
	$(PYTHON) $(BIN)/dump_XMM_sourcelist.py $< > $@

unclustered_sources.txt: $(SOURCES)
	cat $^ | uniq > $@

sources.txt : unclustered_sources.txt
	$(PYTHON) $(BIN)/cluster_srcs.py $(SOURCE_CLSTR_ARCSECS) $< > $@

clean :
	rm -f *.txt *.fits ccf.cif *.pdf *.gz *.grp *.FIT *.MOS emchain epchain core* *mos*
endif
