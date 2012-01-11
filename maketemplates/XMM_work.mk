include $(RAWBASEDIR)/maketemplates/master.mk

GZMOS1S=$(wildcard ../pps/*M1S*EVL*.FTZ)
ifneq ($(GZMOS1S),)
MOS1S=mos1s.fits
endif

GZMOS1U=$(wildcard ../pps/*M1U*EVL*.FTZ)
ifneq ($(GZMOS1U),)
MOS1U=mos1u.fits
endif

GZMOS2S=$(wildcard ../pps/*M2S*EVL*.FTZ)
ifneq ($(GZMOS2S),)
MOS2=mos2s.fits
endif

GZMOS2U=$(wildcard ../pps/*M2U*EVL*.FTZ)
ifneq ($(GZMOS2U),)
MOS2U=mos2u.fits
endif

GZPNS=$(wildcard ../pps/*PNS*EVL*.FTZ)
ifneq ($(GZPNS),)
PNS=pns.fits
endif

GZPNU=$(wildcard ../pps/*PNU*EVL*.FTZ)
ifneq ($(GZPNU),)
PNU=pnu.fits
endif

# We guard against event files not existing
EVT_FILES = $(MOS1S) $(MOS1U) $(MOS2S) $(MOS2U) $(PNS) $(PNU)
LIGHT_CURVES = $(EVT_FILES:.fits=_lightc.fits)
GTI_FILES = $(EVT_FILES:.fits=_gti.fits)
.PRECIOUS : mos1.fits mos2.fits pns.fits pnu.fits ccf.cif

# Determine the ranges for various bands
LOW=300
HIGH=8000
TOP=10000
HLOW=3600
S1HIGH=1300
S2HIGH=3600

# This is the logic
B_BAND=$(patsubst %.fits,%_broad_$(LOW)_$(HIGH)_green_band_img.fits,$(EVT_FILES))
S_BAND=$(patsubst %.fits,%_soft_$(LOW)_$(S2HIGH)_red_band_img.fits,$(EVT_FILES)) 
H_BAND=$(patsubst %.fits,%_hard_$(S2HIGH)_$(HIGH)_blue_band_img.fits,$(EVT_FILES))
S1_BAND=$(patsubst %.fits,%_s1_$(LOW)_$(S1HIGH)_magenta_band_img.fits,$(EVT_FILES))
S2_BAND=$(patsubst %.fits,%_s2_$(S1HIGH)_$(S2HIGH)_cyan_band_img.fits,$(EVT_FILES))
FULL_BAND=$(patsubst %.fits,%_full_$(LOW)_$(TOP)_white_band_img.fits,$(EVT_FILES))

ALL_BANDS=$(B_BAND) $(S_BAND) $(H_BAND) $(S1_BAND) $(S2_BAND) 

.PRECIOUS : $(LIGHT_CURVES) $(GTI_FILES) $(ALL_BANDS)

all : $(GTI_FILES) $(ALL_BANDS)

ccf.cif :
	make -C ../odf untar
	env SAS_ODF=../odf BIN=$(BIN) $(BIN)/cifbuild.sh
	make -C ../odf odfingest

mos1s.fits : $(GZMOS1S)
	gzcat $^ > $@

mos1u.fits : $(GZMOS1U)
	gzcat $^ > $@

mos2s.fits : $(GZMOS2S)
	gzcat $^ > $@

mos2u.fits : $(GZMOS2U)
	gzcat $^ > $@

pns.fits : $(GZPNS)
	gzcat $^ > $@

pnu.fits : $(GZPNU)
	gzcat $^ > $@

mos%_lightc.fits : mos%.fits ccf.cif
	env DATRED=. SAS_ODF=../odf SAS_CCF=ccf.cif BIN=$(BIN) $(BIN)/mos_lightc.sh $< $@

pn%_lightc.fits : pn%.fits ccf.cif
	env DATRED=. SAS_ODF=../odf SAS_CCF=ccf.cif BIN=$(BIN) $(BIN)/pn_lightc.sh $< $@

mos%_gti.fits : mos%_lightc.fits
	env DATRED=. SAS_ODF=../odf SAS_CCF=ccf.cif BIN=$(BIN) $(BIN)/mos_gti.sh $< $@

pn%_gti.fits : pn%_lightc.fits
	env DATRED=. SAS_ODF=../odf SAS_CCF=ccf.cif BIN=$(BIN) $(BIN)/pn_gti.sh $< $@

mos%_broad_$(LOW)_$(HIGH)_green_band_img.fits: mos%.fits mos%_gti.fits 
	env DATRED=. SAS_ODF=../odf SAS_CCF=ccf.cif BIN=$(BIN) $(BIN)/mos_get_band.sh $^ $@ $(shell echo $@ | sed -e 's/_/ /g' | cut -f3,4 -d" ")

pn%_broad_$(LOW)_$(HIGH)_green_band_img.fits: pn%.fits pn%_gti.fits 
	env DATRED=. SAS_ODF=../odf SAS_CCF=ccf.cif BIN=$(BIN) $(BIN)/pn_get_band.sh $^ $@ $(shell echo $@ | sed -e 's/_/ /g' | cut -f3,4 -d" ")

mos%_soft_$(LOW)_$(S2HIGH)_red_band_img.fits: mos%.fits mos%_gti.fits 
	 env DATRED=. SAS_ODF=../odf SAS_CCF=ccf.cif BIN=$(BIN) $(BIN)/mos_get_band.sh $^ $@ $(shell echo $@ | sed -e 's/_/ /g' | cut -f3,4 -d" ")
       
pn%_soft_$(LOW)_$(S2HIGH)_red_band_img.fits: pn%.fits pn%_gti.fits 
	 env DATRED=. SAS_ODF=../odf SAS_CCF=ccf.cif BIN=$(BIN) $(BIN)/pn_get_band.sh $^ $@ $(shell echo $@ | sed -e 's/_/ /g' | cut -f3,4 -d" ")

mos%_hard_$(S2HIGH)_$(HIGH)_blue_band_img.fits: mos%.fits mos%_gti.fits 
	 env DATRED=. SAS_ODF=../odf SAS_CCF=ccf.cif BIN=$(BIN) $(BIN)/mos_get_band.sh $^ $@ $(shell echo $@ | sed -e 's/_/ /g' | cut -f3,4 -d" ")

pn%_hard_$(S2HIGH)_$(HIGH)_blue_band_img.fits: pn%.fits pn%_gti.fits 
	env DATRED=. SAS_ODF=../odf SAS_CCF=ccf.cif BIN=$(BIN) $(BIN)/pn_get_band.sh $^ $@ $(shell echo $@ | sed -e 's/_/ /g' | cut -f3,4 -d" ")

mos%_s1_$(LOW)_$(S1HIGH)_magenta_band_img.fits: mos%.fits mos%_gti.fits 
	 env DATRED=. SAS_ODF=../odf SAS_CCF=ccf.cif BIN=$(BIN) $(BIN)/mos_get_band.sh $^ $@ $(shell echo $@ | sed -e 's/_/ /g' | cut -f3,4 -d" ")

pn%_s1_$(LOW)_$(S1HIGH)_magenta_band_img.fits: pn%.fits pn%_gti.fits 
	env DATRED=. SAS_ODF=../odf SAS_CCF=ccf.cif BIN=$(BIN) $(BIN)/pn_get_band.sh $^ $@ $(shell echo $@ | sed -e 's/_/ /g' | cut -f3,4 -d" ")

mos%_s2_$(S1HIGH)_$(S2HIGH)_cyan_band_img.fits: mos%.fits mos%_gti.fits 
	 env DATRED=. SAS_ODF=../odf SAS_CCF=ccf.cif BIN=$(BIN) $(BIN)/mos_get_band.sh $^ $@ $(shell echo $@ | sed -e 's/_/ /g' | cut -f3,4 -d" ")

pn%_s2_$(S1HIGH)_$(S2HIGH)_cyan_band_img.fits: pn%.fits pn%_gti.fits 
	env DATRED=. SAS_ODF=../odf SAS_CCF=ccf.cif BIN=$(BIN) $(BIN)/pn_get_band.sh $^ $@ $(shell echo $@ | sed -e 's/_/ /g' | cut -f3,4 -d" ")

mos%_full_$(LOW)_$(TOP)_white_band_img.fits: mos%.fits mos%_gti.fits 
	 env DATRED=. SAS_ODF=../odf SAS_CCF=ccf.cif BIN=$(BIN) $(BIN)/mos_get_band.sh $^ $@ $(shell echo $@ | sed -e 's/_/ /g' | cut -f3,4 -d" ")

pn%_full_$(LOW)_$(TOP)_white_band_img.fits: pn%.fits pn%_gti.fits 
	env DATRED=. SAS_ODF=../odf SAS_CCF=ccf.cif BIN=$(BIN) $(BIN)/pn_get_band.sh $^ $@ $(shell echo $@ | sed -e 's/_/ /g' | cut -f3,4 -d" ")

       
clean :
	rm -f *.fits ccf.cif
