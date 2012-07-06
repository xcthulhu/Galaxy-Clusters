include $(RAWBASEDIR)/maketemplates/master.mk
.SECONDARY : 
.PHONY : all clean reprocess
OBSID=$(shell basename $(dir $(shell pwd)))
.DELETE_ON_ERROR : repro decompress

# Designations defined in Kim et al., http://arxiv.org/pdf/astro-ph/0611840
# This obscure webpage says how to translate between XMM and chandra:
# http://heasarc.gsfc.nasa.gov/W3Browse/all/ic10xmmcxo.html
B_BAND=$(OBSID)_evt2_broad_300_8000_green_band.fits
S_BAND=$(OBSID)_evt2_soft_300_2500_red_band.fits
H_BAND=$(OBSID)_evt2_hard_2500_8000_blue_band.fits
S1_BAND=$(OBSID)_evt2_s1_300_900_magenta_band.fits
S2_BAND=$(OBSID)_evt2_s2_900_2500_cyan_band.fits
FULL_BAND=$(OBSID)_evt2_full_300_10000_white_band.fits

BANDFITS=$(B_BAND) $(S_BAND) $(H_BAND) $(S1_BAND) $(S2_BAND) $(FULL_BAND)
BANDSOURCEFITS=$(patsubst %_band.fits,sources/%_band_srcs.fits,$(BANDFITS))
BANDPSF=$(BANDFITS:.fits=_psf.fits)

all : 
	- make sources.txt

# Reprocessing nonsense :(

decompress :
	@for i in ../primary/*.fits.gz ../secondary/*.fits.gz ; do \
		if [ -f $$i ] ; then \
			echo zcat $$i \> `basename $$i | sed -e 's/.gz//'`; \
			zcat $$i > `basename $$i | sed -e 's/.gz//'`; \
		fi \
	done
	@for i in ../primary/*.fits ../secondary/*.fits ; do \
		if [ -f $$i ] ; then \
			echo cp $$i `basename $$i`; \
			cp $$i `basename $$i`; \
		fi \
	done
	touch $@

aspect : ../secondary/aspect
	ln -s $< $@

ephem : ../secondary/ephem
	ln -s $< $@

repro : decompress aspect ephem
	$(CIAO_PYTHON) $(CHANDRA_REPRO) indir=. outdir=. clobber=yes && touch $@

evt2.fits : 
	make repro
	@for i in *repro*evt2.fits ; do \
		if [ -f $$i ] ; then \
			echo ">>> Linking" $$i to $@ "<<<" ; \
			echo ln -sf $$i $@ ; \
			ln -sf $$i $@ ; \
		else \
			echo "COULD NOT LINK ANYTHING TO $@ !" ; \
		fi ; \
		break ; \
	done
	[ -h $@ ] && touch $@

$(OBSID)_evt2.fits : evt2.fits
	ln -sf $< $@
	[ -h $@ ] && touch $@

# Create Images
%_img.fits : %_evt2.fits
	$(CIAO_INIT) && dmcopy "$<[ccd_id=0:3][bin sky=2]" $@ clobber=yes

img.fits : $(OBSID)_img.fits
	ln -fs $< $@

# Detect Images
$(OBSID)_evt2_%_band_psf.fits : img.fits
	$(CIAO_INIT) && mkpsfmap $< outfile=$@ energy=$(shell echo $@ | cut -f4 -d"_") ecf=0.9

$(OBSID)_evt2_%_band.fits : $(OBSID)_evt2.fits
	$(CIAO_INIT) && dmcopy "$<[energy>$(shell echo $@ | cut -f4 -d"_"),energy<$(shell echo $@ | cut -f5 -d"_")][bin sky=2]" $@ clobber=yes

sources :
	mkdir $@

scell : 
	mkdir $@

band_images :
	mkdir $@

nbgd :  
	mkdir $@

band_regs :
	mkdir $@

sources/%_band_srcs.fits : %_band.fits %_band_psf.fits
	$(MAKE) sources scell band_images nbgd band_regs
	rm -f /tmp/$(shell echo $< | sed -e 's/.fits//')*
	$(CIAO_INIT) && wavdetect infile=$< outfile=$@ scellfile=scell/scell-$< imagefile=band_images/imagefile-$< defnbkgfile=nbgd/nbgd-$< regfile=band_regs/$<.reg scales="1.0 1.4 2.0 2.8 4.0 5.6 8" psffile=$(patsubst %.fits,%_psf.fits, $<) clobber=yes

sources.txt : $(BANDSOURCEFITS)
	$(PYTHON) $(BIN)/dump_fits_srcs.py $^ > $@
	
clean : 
	rm -rf *.fits aspect ephem repro decompress *.lis *.par *.lis_* sources.txt sources scell band_images nbgd band_regs 
