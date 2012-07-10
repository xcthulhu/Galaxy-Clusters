include $(RAWBASEDIR)/maketemplates/master.mk

ENCIRCLED_ENERGY_PRECENTAGE=90
MAX_RADIUS=120
STEP=10
INNER_ANNULUS_RADIUS=120
OUTER_ANNULUS_RADIUS=160

# GZipped Event files and rules for making proper event files
GZMOS1S=$(wildcard ../pps/*M1S*EVL*.FTZ)
ifneq ($(GZMOS1S),)
GZMOS1S=$(shell ls ../pps/*M1S*EVL*.FTZ | head -1)
MOS1S=mos1s.fits
MOS1S_ENCIRCLED_ENERGIES=$(patsubst %,sources/encircled_energies/mos1s_energy_%_$(INNER_ANNULUS_RADIUS)_$(OUTER_ANNULUS_RADIUS).txt,$(SOURCES_COORDS))
MOS1S_ENCIRCLED_ENERGY_SUMMARY=sources/encircled_energies/mos1s_$(ENCIRCLED_ENERGY_PRECENTAGE)_percent_energy_source_radii.txt
MOS1S_SOURCE_EVT_BKGS=$(patsubst %,sources/bkgs/%_mos1s_bkg_evts.fits,$(SOURCES_COORDS))
endif

GZMOS1U=$(wildcard ../pps/*M1U*EVL*.FTZ)
ifneq ($(GZMOS1U),)
GZMOS1U=$(shell ls ../pps/*M1U*EVL*.FTZ | head -1)
MOS1U=mos1u.fits
MOS1U_ENCIRCLED_ENERGIES=$(patsubst %,sources/encircled_energies/mos1u_energy_%_$(INNER_ANNULUS_RADIUS)_$(OUTER_ANNULUS_RADIUS).txt,$(SOURCES_COORDS))
MOS1U_ENCIRCLED_ENERGY_SUMMARY=sources/encircled_energies/mos1u_$(ENCIRCLED_ENERGY_PRECENTAGE)_percent_energy_source_radii.txt
MOS1U_SOURCE_EVT_BKGS=$(patsubst %,sources/bkgs/%_mos1u_bkg_evts.fits,$(SOURCES_COORDS))
endif

GZMOS2S=$(wildcard ../pps/*M2S*EVL*.FTZ)
ifneq ($(GZMOS2S),)
GZMOS2S=$(shell ls ../pps/*M2S*EVL*.FTZ | head -1)
MOS2S=mos2s.fits
MOS2S_ENCIRCLED_ENERGIES=$(patsubst %,sources/encircled_energies/mos2s_energy_%_$(INNER_ANNULUS_RADIUS)_$(OUTER_ANNULUS_RADIUS).txt,$(SOURCES_COORDS))
MOS2S_ENCIRCLED_ENERGY_SUMMARY=sources/encircled_energies/mos2s_$(ENCIRCLED_ENERGY_PRECENTAGE)_percent_energy_source_radii.txt
MOS2S_SOURCE_EVT_BKGS=$(patsubst %,sources/bkgs/%_mos2s_bkg_evts.fits,$(SOURCES_COORDS))
endif

GZMOS2U=$(wildcard ../pps/*M2U*EVL*.FTZ)
ifneq ($(GZMOS2U),)
GZMOS2U=$(shell ls ../pps/*M2U*EVL*.FTZ | head -1)
MOS2U=mos2u.fits
MOS2U_ENCIRCLED_ENERGIES=$(patsubst %,sources/encircled_energies/mos2u_energy_%_$(INNER_ANNULUS_RADIUS)_$(OUTER_ANNULUS_RADIUS).txt,$(SOURCES_COORDS))
MOS2U_ENCIRCLED_ENERGY_SUMMARY=sources/encircled_energies/mos2u_$(ENCIRCLED_ENERGY_PRECENTAGE)_percent_energy_source_radii.txt
MOS2U_SOURCE_EVT_BKGS=$(patsubst %,sources/bkgs/%_mos2u_bkg_evts.fits,$(SOURCES_COORDS))
endif

GZPNS=$(wildcard ../pps/*PNS*EVL*.FTZ)
ifneq ($(GZPNS),)
GZPNS=$(shell ls ../pps/*PNS*EVL*.FTZ | head -1)
PNS=pns.fits
PNS_ENCIRCLED_ENERGIES=$(patsubst %,sources/encircled_energies/pns_energy_%_$(INNER_ANNULUS_RADIUS)_$(OUTER_ANNULUS_RADIUS).txt,$(SOURCES_COORDS))
PNS_ENCIRCLED_ENERGY_SUMMARY=sources/encircled_energies/pns_$(ENCIRCLED_ENERGY_PRECENTAGE)_percent_energy_source_radii.txt
PNS_SOURCE_EVT_BKGS=$(patsubst %,sources/bkgs/%_pns_bkg_evts.fits,$(SOURCES_COORDS))
endif

GZPNU=$(wildcard ../pps/*PNU*EVL*.FTZ)
ifneq ($(GZPNU),)
GZPNU=$(shell ls ../pps/*PNU*EVL*.FTZ | head -1)
PNU=pnu.fits
PNU_ENCIRCLED_ENERGIES=$(patsubst %,sources/encircled_energies/pnu_energy_%_$(INNER_ANNULUS_RADIUS)_$(OUTER_ANNULUS_RADIUS).txt,$(SOURCES_COORDS))
PNU_ENCIRCLED_ENERGY_SUMMARY=sources/encircled_energies/pnu_$(ENCIRCLED_ENERGY_PRECENTAGE)_percent_energy_source_radii.txt
PNU_SOURCE_EVT_BKGS=$(patsubst %,sources/bkgs/%_pnu_bkg_evts.fits,$(SOURCES_COORDS))
endif

# GZipped Satellite Attitude file
GZATT=$(wildcard ../pps/*ATT*.FTZ)

# We guard against event files not existing ; we also don't bother to do anything if 
# we can't figure out the satellite's attitude
ifneq ($(GZATT),)
EVT_FILES = $(MOS1S) $(MOS1U) $(MOS2S) $(MOS2U) $(PNS) $(PNU)
endif
LIGHT_CURVES = $(EVT_FILES:.fits=_lightc.fits)
GTI_FILES = $(EVT_FILES:.fits=_gti.fits)
FILT_EVT_FILES = $(EVT_FILES:.fits=_filt.fits)
DS9_IMG_FILES = $(EVT_FILES:.fits=_ds9_img.fits)
DS9_IMG_PDFS = $(EVT_FILES:.fits=_ds9_img.pdf)

# Encircled energy summary targets
ENCIRCLED_ENERGY_SUMMARIES=$(MOS1S_ENCIRCLED_ENERGY_SUMMARY) \
			   $(MOS1U_ENCIRCLED_ENERGY_SUMMARY) \
			   $(MOS2S_ENCIRCLED_ENERGY_SUMMARY) \
			   $(MOS2U_ENCIRCLED_ENERGY_SUMMARY) \
			   $(PNS_ENCIRCLED_ENERGY_SUMMARY) \
			   $(PNU_ENCIRCLED_ENERGY_SUMMARY)

# Determine the ranges for various bands
BOT=200
B1END=500
B2END=1000
B3END=2000
B4END=4500
TOP=12000

# From the eventfiles, we generate other files names, which describe bandpasses we will perform
B1_BAND=$(patsubst %.fits,%_b1_img.fits,$(EVT_FILES))
B1_NAME=$(patsubst %.fits,%_b1_$(BOT)_$(B1END)_green_band_img.fits,$(EVT_FILES))
B2_BAND=$(patsubst %.fits,%_b2_img.fits,$(EVT_FILES)) 
B2_NAME=$(patsubst %.fits,%_b2_$(B1END)_$(B2END)_red_band_img.fits,$(EVT_FILES))
B3_BAND=$(patsubst %.fits,%_b3_img.fits,$(EVT_FILES))
B3_NAME=$(patsubst %.fits,%_b3_$(B2END)_$(B3END)_blue_band_img.fits,$(EVT_FILES))
B4_BAND=$(patsubst %.fits,%_b4_img.fits,$(EVT_FILES))
B4_NAME=$(patsubst %.fits,%_b4_$(B3END)_$(B4END)_magenta_band_img.fits,$(EVT_FILES))
B5_BAND=$(patsubst %.fits,%_b5_img.fits,$(EVT_FILES))
B5_NAME=$(patsubst %.fits,%_b5_$(B4END)_$(TOP)_cyan_band_img.fits,$(EVT_FILES))
FULL_BAND=$(patsubst %.fits,%_full_img.fits,$(EVT_FILES))
FULL_NAME=$(patsubst %.fits,%_full_$(BOT)_$(TOP)_white_band_img.fits,$(EVT_FILES))
ALL_BANDS=$(B1_BAND) $(B2_BAND) $(B3_BAND) $(B4_BAND) $(B5_BAND) $(FULL_BAND)
ALL_NAMES=$(B1_NAME) $(B2_NAME) $(B3_NAME) $(B4_NAME) $(B5_NAME) $(FULL_NAME)

SOURCES=$(EVT_FILES:.fits=_emllist.fits)


ifneq ($(SOURCES),)
SOURCES_TXT=sources.txt
SOURCES_COORDS=$(shell test -e sources.txt && sed -e 's/ \t/_/g' sources.txt)
endif

SOURCE_EVT_BKGS=$(MOS1S_SOURCE_EVT_BKGS) $(MOS1U_SOURCE_EVT_BKGS) $(MOS2S_SOURCE_EVT_BKGS) $(MOS2U_SOURCE_EVT_BKGS) $(PNS_SOURCE_EVT_BKGS) $(PNU_SOURCE_EVT_BKGS)
SOURCE_EVT_BKGS_PIS=$(patsubst sources/bkgs/%_bkg_evts.fits, sources/PI/%_bkg_evts_pi.fits, $(SOURCE_EVT_BKGS))

.SECONDARY : 
.PHONY: all lightcurves gti source_background_evts 

all : ccf.cif $(GTI_FILES) $(ALL_BANDS) $(ALL_NAMES) $(EVT_FILES) $(SOURCES_TXT) $(FILT_EVT_FILES)

test :
	echo $(SOURCES)

lightcurves: $(LIGHT_CURVES)

gti : $(GTI_FILES) 

images : $(DS9_IMG_PDFS)

source_background_evts : $(SOURCES_TXT)

source_background_evts_pi : $(SOURCES_TXT)

encircled_energies : $(PNS_ENCIRCLED_ENERGY_SUMMARY) #$(ENCIRCLED_ENERGY_SUMMARIES)

# Compute encircled energy
sources/encircled_energies/mos1s_energy_%_$(INNER_ANNULUS_RADIUS)_$(OUTER_ANNULUS_RADIUS).txt : mos1s_ds9_img.fits
	$(BIN)/encircled_energy_scan.sh $< $(shell echo $@ | sed -e 's/_/ /g' | cut -d' ' -f4,5) $(STEP) $(MAX_RADIUS) $(INNER_ANNULUS_RADIUS) $(OUTER_ANNULUS_RADIUS) $@

sources/encircled_energies/mos1u_energy_%_$(INNER_ANNULUS_RADIUS)_$(OUTER_ANNULUS_RADIUS).txt : mos1u_ds9_img.fits
	$(BIN)/encircled_energy_scan.sh $< $(shell echo $@ | sed -e 's/_/ /g' | cut -d' ' -f4,5) $(STEP) $(MAX_RADIUS) $(INNER_ANNULUS_RADIUS) $(OUTER_ANNULUS_RADIUS) $@

sources/encircled_energies/mos2s_energy_%_$(INNER_ANNULUS_RADIUS)_$(OUTER_ANNULUS_RADIUS).txt : mos2s_ds9_img.fits
	$(BIN)/encircled_energy_scan.sh $< $(shell echo $@ | sed -e 's/_/ /g' | cut -d' ' -f4,5) $(STEP) $(MAX_RADIUS) $(INNER_ANNULUS_RADIUS) $(OUTER_ANNULUS_RADIUS) $@

sources/encircled_energies/mos2u_energy_%_$(INNER_ANNULUS_RADIUS)_$(OUTER_ANNULUS_RADIUS).txt : mos2u_ds9_img.fits
	$(BIN)/encircled_energy_scan.sh $< $(shell echo $@ | sed -e 's/_/ /g' | cut -d' ' -f4,5) $(STEP) $(MAX_RADIUS) $(INNER_ANNULUS_RADIUS) $(OUTER_ANNULUS_RADIUS) $@

sources/encircled_energies/pns_energy_%_$(INNER_ANNULUS_RADIUS)_$(OUTER_ANNULUS_RADIUS).txt : pns_ds9_img.fits
	$(BIN)/encircled_energy_scan.sh $< $(shell echo $@ | sed -e 's/_/ /g' | cut -d' ' -f4,5) $(STEP) $(MAX_RADIUS) $(INNER_ANNULUS_RADIUS) $(OUTER_ANNULUS_RADIUS) $@

sources/encircled_energies/pnu_energy_%_$(INNER_ANNULUS_RADIUS)_$(OUTER_ANNULUS_RADIUS).txt : pnu_ds9_img.fits
	$(BIN)/encircled_energy_scan.sh $< $(shell echo $@ | sed -e 's/_/ /g' | cut -d' ' -f4,5) $(STEP) $(MAX_RADIUS) $(INNER_ANNULUS_RADIUS) $(OUTER_ANNULUS_RADIUS) $@

#sources/encircled_energies/%_$(ENCIRCLED_ENERGY_PRECENTAGE)_percent_energy_source_radii.txt : %_ds9_img.fits sources.txt 
#	$(BIN)/est_encircle_energy.py $(ENCIRCLED_ENERGY_PRECENTAGE) $(dir $@)/$<* | tee $@

ifneq ($(MOS1S_ENCIRCLED_ENERGY_SUMMARY),)
$(MOS1S_ENCIRCLED_ENERGY_SUMMARY) : $(MOS1S_ENCIRCLED_ENERGIES)
	rm -f $@
	$(BIN)/est_encircle_energy.py $(ENCIRCLED_ENERGY_PRECENTAGE) $^ | tee $@
endif
ifneq ($(MOS1U_ENCIRCLED_ENERGY_SUMMARY),)
$(MOS1U_ENCIRCLED_ENERGY_SUMMARY) : $(MOS1U_ENCIRCLED_ENERGIES)
	rm -f $@
	$(BIN)/est_encircle_energy.py $(ENCIRCLED_ENERGY_PRECENTAGE) $^ | tee $@
endif
ifneq ($(MOS2S_ENCIRCLED_ENERGY_SUMMARY),)
$(MOS2S_ENCIRCLED_ENERGY_SUMMARY) : $(MOS2S_ENCIRCLED_ENERGIES)
	rm -f $@
	$(BIN)/est_encircle_energy.py $(ENCIRCLED_ENERGY_PRECENTAGE) $^ | tee $@
endif
ifneq ($(MOS2U_ENCIRCLED_ENERGY_SUMMARY),)
$(MOS2U_ENCIRCLED_ENERGY_SUMMARY) : $(MOS2U_ENCIRCLED_ENERGIES)
	rm -f $@
	$(BIN)/est_encircle_energy.py $(ENCIRCLED_ENERGY_PRECENTAGE) $^ | tee $@
endif
ifneq ($(PNS_ENCIRCLED_ENERGY_SUMMARY),)
$(PNS_ENCIRCLED_ENERGY_SUMMARY) : $(PNS_ENCIRCLED_ENERGIES)
	rm -f $@
	$(BIN)/est_encircle_energy.py $(ENCIRCLED_ENERGY_PRECENTAGE) $^ | tee $@
endif
ifneq ($(PNU_ENCIRCLED_ENERGY_SUMMARY),)
$(PNU_ENCIRCLED_ENERGY_SUMMARY)  : $(PNU_ENCIRCLED_ENERGIES)
	rm -f $@
	$(BIN)/est_encircle_energy.py $(ENCIRCLED_ENERGY_PRECENTAGE) $^ | tee $@
endif

ccf.cif :
	make -C ../odf untar
	$(BIN)/cifbuild.sh
	make -C ../odf odfingest

attds.fits.gz : $(GZATT)
	cp -f $^ $@

mos1s.fits.gz : $(GZMOS1S)
	cp -f $^ $@

mos%.fits : mos%.fits.gz 
	zcat $< > $@

pn%.fits : pn%.fits.gz 
	zcat $< > $@

mos1u.fits.gz : $(GZMOS1U)
	cp -f $^ $@

mos2s.fits.gz : $(GZMOS2S)
	cp -f $^ $@

mos2u.fits.gz : $(GZMOS2U)
	cp -f $^ $@

pns.fits.gz : $(GZPNS)
	cp -f $^ $@

pnu.fits.gz : $(GZPNU)
	cp -f $^ $@

%_ds9_img.pdf : %_ds9_img.fits
	$(BIN)/fits_show.py $< $@

%_ds9_img.fits : %.fits
	$(BIN)/mk_XMM_image.sh $< $@

# Compute the backgrounds for all of the events for all of the detectors

sources/bkgs :
	mkdir -p $@

sources/bkgs/%_mos1s_bkg_evts.fits : mos1s.fits sources/bkgs
	$(BIN)/mk_XMM_background.py $< $(shell echo $(notdir $@) | sed -e 's/_/ /g' | cut -f1,2 -d" ") 130 160 $@

sources/bkgs/%_mos1u_bkg_evts.fits : mos1u.fits sources/bkgs
	$(BIN)/mk_XMM_background.py $< $(shell echo $(notdir $@) | sed -e 's/_/ /g' | cut -f1,2 -d" ") 130 160 $@

sources/bkgs/%_mos2s_bkg_evts.fits : mos2s.fits sources/bkgs
	$(BIN)/mk_XMM_background.py $< $(shell echo $(notdir $@) | sed -e 's/_/ /g' | cut -f1,2 -d" ") 130 160 $@

sources/bkgs/%_mos2u_bkg_evts.fits : mos2u.fits sources/bkgs
	$(BIN)/mk_XMM_background.py $< $(shell echo $(notdir $@) | sed -e 's/_/ /g' | cut -f1,2 -d" ") 130 160 $@

sources/bkgs/%_pns_bkg_evts.fits : pns.fits sources/bkgs
	$(BIN)/mk_XMM_background.py $< $(shell echo $(notdir $@) | sed -e 's/_/ /g' | cut -f1,2 -d" ") 130 160 $@

sources/bkgs/%_pnu_bkg_evts.fits : pnu.fits sources/bkgs
	$(BIN)/mk_XMM_background.py $< $(shell echo $(notdir $@) | sed -e 's/_/ /g' | cut -f1,2 -d" ") 130 160 $@

# Compute the PIs for all of the background events

sources/PI :
	mkdir -p $@

sources/PI/%_mos1s_bkg_evts_pi.fits : sources/bkgs/%_mos1s_bkg_evts.fits sources/PI
	$(BIN)/XMM_mos_bckg_pi.sh $< $@

sources/PI/%_mos1u_bkg_evts_pi.fits : sources/bkgs/%_mos1u_bkg_evts.fits sources/PI
	$(BIN)/XMM_mos_bckg_pi.sh $< $@

sources/PI/%_mos2s_bkg_evts_pi.fits : sources/bkgs/%_mos2s_bkg_evts.fits sources/PI
	$(BIN)/XMM_mos_bckg_pi.sh $< $@

sources/PI/%_mos2u_bkg_evts_pi.fits : sources/bkgs/%_mos2u_bkg_evts.fits sources/PI
	$(BIN)/XMM_mos_bckg_pi.sh $< $@

sources/PI/%_pns_bkg_evts_pi.fits : sources/bkgs/%_pns_bkg_evts.fits sources/PI
	$(BIN)/XMM_pn_bckg_pi.sh $< $@

sources/PI/%_pnu_bkg_evts_pi.fits : sources/bkgs/%_pnu_bkg_evts.fits sources/PI
	$(BIN)/XMM_pn_bckg_pi.sh $< $@

# Compute light curves for each detector

mos%_lightc.fits : mos%.fits.gz ccf.cif
	$(BIN)/mos_lightc.sh $< $@

pn%_lightc.fits : pn%.fits.gz ccf.cif
	$(BIN)/pn_lightc.sh $< $@

mos%_gti.fits : mos%_lightc.fits
	$(BIN)/mos_gti.sh $< $@

pn%_gti.fits : pn%_lightc.fits
	$(BIN)/pn_gti.sh $< $@

%_filt.fits : %.fits %_gti.fits
	$(BIN)/XMM_filtered_evt.sh $^ $@

%_b1_img.fits: %_b1_$(BOT)_$(B1END)_green_band_img.fits
	ln -sf $< $@

mos%_b1_$(BOT)_$(B1END)_green_band_img.fits: mos%.fits.gz mos%_gti.fits
	$(BIN)/mos_get_band.sh $^ $@ $(shell echo $@ | sed -e 's/_/ /g' | cut -f3,4 -d" ")

pn%_b1_$(BOT)_$(B1END)_green_band_img.fits: pn%.fits.gz pn%_gti.fits 
	$(BIN)/pn_get_band.sh $^ $@ $(shell echo $@ | sed -e 's/_/ /g' | cut -f3,4 -d" ")

%_b2_img.fits: %_b2_$(B1END)_$(B2END)_red_band_img.fits
	ln -sf $< $@

mos%_b2_$(B1END)_$(B2END)_red_band_img.fits: mos%.fits.gz mos%_gti.fits 
	$(BIN)/mos_get_band.sh $^ $@ $(shell echo $@ | sed -e 's/_/ /g' | cut -f3,4 -d" ")
       
pn%_b2_$(B1END)_$(B2END)_red_band_img.fits: pn%.fits.gz pn%_gti.fits 
	$(BIN)/pn_get_band.sh $^ $@ $(shell echo $@ | sed -e 's/_/ /g' | cut -f3,4 -d" ")

%_b3_img.fits: %_b3_$(B2END)_$(B3END)_blue_band_img.fits
	ln -sf $< $@

mos%_b3_$(B2END)_$(B3END)_blue_band_img.fits: mos%.fits.gz mos%_gti.fits 
	$(BIN)/mos_get_band.sh $^ $@ $(shell echo $@ | sed -e 's/_/ /g' | cut -f3,4 -d" ")

pn%_b3_$(B2END)_$(B3END)_blue_band_img.fits: pn%.fits.gz pn%_gti.fits 
	$(BIN)/pn_get_band.sh $^ $@ $(shell echo $@ | sed -e 's/_/ /g' | cut -f3,4 -d" ")

%_b4_img.fits: %_b4_$(B3END)_$(B4END)_magenta_band_img.fits
	ln -sf $< $@

mos%_b4_$(B3END)_$(B4END)_magenta_band_img.fits: mos%.fits.gz mos%_gti.fits 
	$(BIN)/mos_get_band.sh $^ $@ $(shell echo $@ | sed -e 's/_/ /g' | cut -f3,4 -d" ")

pn%_b4_$(B3END)_$(B4END)_magenta_band_img.fits: pn%.fits.gz pn%_gti.fits 
	$(BIN)/pn_get_band.sh $^ $@ $(shell echo $@ | sed -e 's/_/ /g' | cut -f3,4 -d" ")

%_b5_img.fits: %_b5_$(B4END)_$(TOP)_cyan_band_img.fits
	ln -sf $< $@

mos%_b5_$(B4END)_$(TOP)_cyan_band_img.fits: mos%.fits.gz mos%_gti.fits 
	$(BIN)/mos_get_band.sh $^ $@ $(shell echo $@ | sed -e 's/_/ /g' | cut -f3,4 -d" ")

pn%_b5_$(B4END)_$(TOP)_cyan_band_img.fits: pn%.fits.gz pn%_gti.fits 
	$(BIN)/pn_get_band.sh $^ $@ $(shell echo $@ | sed -e 's/_/ /g' | cut -f3,4 -d" ")

%_full_img.fits: %_full_$(BOT)_$(TOP)_white_band_img.fits
	ln -sf $< $@

mos%_full_$(BOT)_$(TOP)_white_band_img.fits: mos%.fits.gz mos%_gti.fits 
	$(BIN)/mos_get_band.sh $^ $@ $(shell echo $@ | sed -e 's/_/ /g' | cut -f3,4 -d" ")

pn%_full_$(BOT)_$(TOP)_white_band_img.fits: pn%.fits.gz pn%_gti.fits 
	$(BIN)/pn_get_band.sh $^ $@ $(shell echo $@ | sed -e 's/_/ /g' | cut -f3,4 -d" ")

mos1%_emllist.fits: mos1%.fits.gz attds.fits.gz mos1%_b1_img.fits mos1%_b2_img.fits mos1%_b3_img.fits mos1%_b4_img.fits mos1%_b5_img.fits
	rm -f *$@ *$(shell echo $@ | sed -e 's/mos1/mos2/')
	-$(BIN)/mos1_source_detect.sh $@ $^

mos2%_emllist.fits: mos2%.fits.gz attds.fits.gz mos2%_b1_img.fits mos2%_b2_img.fits mos2%_b3_img.fits mos2%_b4_img.fits mos2%_b5_img.fits
	rm -f *$@ *$(shell echo $@ | sed -e 's/mos2/mos1/')
	-$(BIN)/mos2_source_detect.sh $@ $^

pn%_emllist.fits: pn%.fits.gz attds.fits.gz pn%_b1_img.fits pn%_b2_img.fits pn%_b3_img.fits pn%_b4_img.fits pn%_b5_img.fits
	rm -f *$@
	$(BIN)/pn_source_detect.sh $@ $^

sources.txt: $(SOURCES)
	$(PYTHON) $(BIN)/dump_XMM_sourcelist.py $^ | uniq > $@

clean :
	rm -f *.txt *.fits ccf.cif *.pdf *.gz *.grp
