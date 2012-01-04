include $(RAWBASEDIR)/maketemplates/master.mk

OBSID=$(notdir $(shell pwd))

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

OBJS=$(OBSID)_evt2.tsv $(OBSID)_evt2.headers img.fits $(BANDFITS) $(BANDSOURCEFITS)

.PHONY : all clean reprocess

all : $(OBJS)
	make -C primary reprocess

# Rules for creating & linking the evt2 file
$(OBSID)_evt2.fits : primary/evt2.fits
	ln -sf $< $@
	[ -h $@ ] && touch $@

primary/evt2.fits : primary/Makefile
	$(MAKE) -C $(dir $@) $(notdir $@)
	[ -h $@ ] && touch $@

primary/Makefile : 
	echo RAWBASEDIR=$(RAWBASEDIR)/.. > $@
	echo include '$$(RAWBASEDIR)'/maketemplates/chandra_primary.mk >> $@

# Rules for creating & linking the evt1 file
$(OBSID)_evt1.fits : secondary/evt1.fits
	ln -sf $< $@
	[ -h $@ ] && touch $@

secondary/evt1.fits : secondary/Makefile
	$(MAKE) -C $(dir $@) $(notdir $@)
	[ -h $@ ] && touch $@

secondary/Makefile : 
	echo RAWBASEDIR=$(RAWBASEDIR)/.. > $@
	echo include '$$(RAWBASEDIR)'/maketemplates/chandra_secondary.mk >> $@

# Rules for extracting a human being readable file from an EVT2 file
%_evt2.headers : %_evt2.fits
	$(CIAO_INIT) && dmlist "$<[2]" opt=cols > $@

# We just dump all of the contents of the evt2 file to output,
# parse and create a proper TSV
%_evt2.tsv : %_evt2.fits %_evt2.headers $(BIN)/parse_dmlist_output.py
	$(CIAO_INIT) && dmlist "$<[cols time,energy,sky,EQPOS]" data rows=1: | tail -n +8 | $(PYTHON) $(BIN)/parse_dmlist_output.py > $@

# Image creation from evt2 files is discussed here:
# http://cxc.harvard.edu/ciao/threads/reproject_image/
%_img.fits : %_evt2.fits
	$(CIAO_INIT) && dmcopy "$<[ccd_id=0:3][bin sky=2]" $@ clobber=yes

img.fits : $(OBSID)_img.fits
	ln -s $< $@

# Rules for detecting sources from a given band
$(OBSID)_evt2_%_band.fits : $(OBSID)_evt2.fits
	$(CIAO_INIT) && dmcopy "$<[energy>$(shell echo $@ | cut -f3 -d"_"),energy<$(shell echo $@ | cut -f4 -d"_")][bin sky=2]" $@ clobber=yes

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

sources/%_band_srcs.fits : %_band.fits
	$(MAKE) sources scell band_images nbgd band_regs
	rm -f /tmp/$(shell echo $< | sed -e 's/.fits//')*
	$(CIAO_INIT) && wavdetect infile=$< outfile=$@ scellfile=scell/scell-$< imagefile=band_images/imagefile-$< defnbkgfile=nbgd/nbgd-$< regfile=band_regs/$<.reg scales="1.0 1.414 2.0 2.828 4.0 5.657 8" clobber=yes

clustered_sources : $(BANDSOURCEFITS)
	$(PYTHON) $(BIN)/cluster_fits_srcs.py $(SRC_CLSTR_RADIUS) $@ $^

clean : primary/Makefile secondary/Makefile
	rm -rf $(OBJS) sources scell band_images nbgd band_regs *$(OBSID)*.fits $(OBSID)*.reg *$(OBSID)*.header img.fits
	$(MAKE) -C primary clean
	$(MAKE) -C secondary clean
