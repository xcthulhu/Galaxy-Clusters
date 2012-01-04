include $(RAWBASEDIR)/maketemplates/master.mk

GZMOS1=../pps/*M1*EVL*.FTZ
GZMOS2=../pps/*M2*EVL*.FTZ
GZPNS=$(wildcard ../pps/*PNS*EVL*.FTZ)
ifneq ($(GZPNS),)
PNS=pns.fits
endif

GZPNU=$(wildcard ../pps/*PNU*EVL*.FTZ)
ifneq ($(GZPNU),)
PNU=pnu.fits
endif


# PNU doesn't always exist
EVT_FILES = mos1.fits mos2.fits $(PNS) $(PNU)

B_BAND=$(patsubst %.fits,%_broad_300_8000_green_band_img.fits,$(EVT_FILES))
S_BAND=$(patsubst %.fits,%_soft_300_2500_red_band_img.fits,$(EVT_FILES)) 
H_BAND=$(patsubst %.fits,%_hard_2500_8000_blue_band_img.fits,$(EVT_FILES))
S1_BAND=$(patsubst %.fits,%_s1_300_900_magenta_band_img.fits,$(EVT_FILES))
S2_BAND=$(patsubst %.fits,%_s2_900_2500_cyan_band_img.fits,$(EVT_FILES))
FULL_BAND=$(patsubst %.fits,%_full_300_10000_white_band_img.fits,$(EVT_FILES))


all : ccf.cif $(B_BAND)

ccf.cif :
	make -C ../odf untar
	env SAS_ODF=../odf BIN=$(BIN) $(BIN)/cifbuild.sh
	make -C ../odf odfingest

%_broad_300_8000_green_band_img.fits : %.fits
	echo $(shell echo $@ | cut -f3 -d"_")

mos1.fits : $(GZMOS1) 
	gzcat $^ > $@

mos2.fits : $(GZMOS2)
	gzcat $^ > $@

pns.fits : $(GZPNS)
	gzcat $^ > $@

pnu.fits : $(GZPNU)
	gzcat $^ > $@

clean :
	rm -f *.fits ccf.cif
