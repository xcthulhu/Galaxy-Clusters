include $(RAWBASEDIR)/maketemplates/master.mk
.SECONDARY : 
.PHONY:all clean srcsouts
SRCSFITS=$(BANDFITS:_band.fits=_band_srcs.fits)
WINDOWEVT2=$(XMIN)_$(XMAX)_$(YMIN)_$(YMAX)_$(EVT2)

# Designations defined in Kim et al., http://arxiv.org/pdf/astro-ph/0611840
# This obscure webpage says how to translate between XMM and chandra:
# http://heasarc.gsfc.nasa.gov/W3Browse/all/ic10xmmcxo.html
B_BAND=$(WINDOWEVT2:.fits=_evt2_broad-300-8000-green_band.fits)
S_BAND=$(WINDOWEVT2:.fits=_evt2_soft-300-2500-red_band.fits)
H_BAND=$(WINDOWEVT2:.fits=_evt2_hard-2500-8000-blue_band.fits)
S1_BAND=$(WINDOWEVT2:.fits=_evt2_s1-300-900-magenta_band.fits)
S2_BAND=$(WINDOWEVT2:.fits=_evt2_s2-900-2500-cyan_band.fits)
FULL_BAND=$(WINDOWEVT2:.fits=_evt2_full-300-10000-white_band.fits)
BANDFITS=$(B_BAND) $(S_BAND) $(H_BAND) $(S1_BAND) $(S2_BAND) $(FULL_BAND)
BANDPSF=$(BANDFITS:.fits=_psf.fits)
SRCSFITS=$(BANDFITS:.fits=_srcs.fits)
SRCSTXTS=$(BANDFITS:.fits=_srcs.txt)

all : sources.txt

$(WINDOWEVT2) : ../../$(EVT2)
	ln -s $< $@

%_band.fits : $(WINDOWEVT2)
	$(CIAO_INIT) && dmcopy "$<[energy>$(shell echo $@ | cut -f2 -d"-"),energy<$(shell echo $@ | cut -f3 -d"-")][bin x=$(XMIN):$(XMAX):$(CHANDRA_BINNING),y=$(YMIN):$(YMAX):$(CHANDRA_BINNING)]" $@ clobber=yes

%_band_psf.fits : %_band.fits
	$(CIAO_INIT) && mkpsfmap $< outfile=$@ energy=$(shell echo $@ | cut -f2 -d"-") ecf=0.9 clobber=yes

scell band_images nbgd band_regs :
	mkdir -p $@

%_band_srcs.fits : %_band.fits %_band_psf.fits
	make scell band_images nbgd band_regs
	$(CIAO_INIT) && wavdetect interdir=$(shell env TMPDIR=$(CURDIR) mktemp -d) infile=$< outfile=$@ scellfile=scell/scell-$< imagefile=band_images/imagefile-$< defnbkgfile=nbgd/nbgd-$< regfile=band_regs/$<.reg scales="1.0 1.4 2.0 2.8 4.0 5.6 8 11.3 16.0" psffile=$(<:.fits=_psf.fits) clobber=yes 

%_band_srcs.txt : %_band_srcs.fits 
	$(PYTHON) $(BIN)/dump_fits_srcs.py $< > $@

unclustered_sources.txt : $(SRCSTXTS)
	cat $^ | sort | uniq > $@

sources.txt : unclustered_sources.txt
	$(PYTHON) $(BIN)/cluster_srcs.py $(SOURCE_CLSTR_ARCSECS) $< > $@

sources.out : $(BANDFITS:.fits=_srcs.out)
	touch $@

%_srcs.sh : $(WINDOWEVT2)
	echo '#!/bin/bash' > $@
	echo 'export LD_LIBRARY_PATH=${HOME}/lib:${HOME}/lib64' >> $@
	echo "make -C $(CURDIR) $(patsubst %.sh,%.txt,$@)" >> $@
	echo "echo DONE" >> $@
	chmod +x $@

X%X.sh : %.sh
	beo-gensge.pl -N $(patsubst %.sh,%,$@) -c ./$< -j n -o $(patsubst %.sh,%.out,$<) -e $(patsubst %.sh,%.error,$<) -t "2:00:00" -p n  

%.out %.error : X%X.sh
	qsub $<

clean : 
	rm -rf *.fits scell band_images nbgd band_regs *.txt *.out *.error *.sh core* tmp.*
