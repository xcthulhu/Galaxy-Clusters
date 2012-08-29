include $(RAWBASEDIR)/maketemplates/master.mk
.SECONDARY : 
.PHONY : all clean bandouts
.DELETE_ON_ERROR : 

# Designations defined in Kim et al., http://arxiv.org/pdf/astro-ph/0611840
# This obscure webpage says how to translate between XMM and chandra:
# http://heasarc.gsfc.nasa.gov/W3Browse/all/ic10xmmcxo.html
all : sources.txt

asol.fits : ../work/asol.fits
	ln -sf $< $@ && touch $@

../work/asol.fits :
	make -C ../work asol.fits

sources.txt : sourcesd/sources.txt
	ln -sf $< $@
	touch $@

sourcesd/sources.txt : sourcesd sourcesd/Makefile
	make -C $< sources.txt
	touch $@

sourcesd :
	mkdir -p $@

sourcesd/Makefile : sourcesd $(EVT2)
	echo RAWBASEDIR=$(RAWBASEDIR)/.. > $@
	echo EVT2=$(EVT2) >> $@
	echo ITER_VALS=$(shell seq 0 $(CHANDRA_STEP_SIZE) $(shell echo 4608 - $(CHANDRA_WINDOW_SIZE) | bc)) >> $@
	echo include '$$(RAWBASEDIR)'/maketemplates/chandra_sources.mk >> $@

master-sizes.txt : master_sources.txt $(patsubst %,sizes-%.txt, $(BANDS))
	paste $^ > $@

sizes-%.txt : master_sources.txt asol.fits
	rm -f $@
	$(CIAO_INIT) && while read p ; do \
		echo $(BIN)/psffrac.py $(EVT2) asol.fits `echo $$p | cut -d' ' -f1` `echo $$p | cut -d' ' -f2` $(patsubst sizes-%.txt,%,$@) '>> $@'; \
		$(BIN)/psffrac.py $(EVT2) asol.fits `echo $$p | cut -d' ' -f1` `echo $$p | cut -d' ' -f2` $(patsubst sizes-%.txt,%,$@) >> $@; \
	done < $<

../master_sources.txt : 
	make -C .. master_sources.txt

master_sources.txt : ../master_sources.txt
	ln -sf $< $@ && touch $@

psfouts: $(BANDPSF:.fits=.out)
imgout : $(EVT2:.fits=_img.out)

$(EVT2) : ../work/$(EVT2)
	ln -sf $< $@
	touch $@

# Create Images
img.fits : $(EVT2)
	$(CIAO_INIT) && dmcopy "$<[ccd_id=0:3][bin sky=1][opt mem=135]" $@ clobber=yes

master-sizes.sh :
	echo '#!/bin/bash' > $@
	echo 'export LD_LIBRARY_PATH=${HOME}/lib:${HOME}/lib64' >> $@
	echo "make -C $(CURDIR) $(patsubst %.sh,%.txt,$@)" >> $@
	chmod +x $@

sources.sh : $(EVT2)
	echo '#!/bin/bash' > $@
	echo 'export LD_LIBRARY_PATH=${HOME}/lib:${HOME}/lib64' >> $@
	echo "make -C $(CURDIR) sources.txt" >> $@
	chmod +x $@

%X.sh : %.sh
	beo-gensge.pl -N $(patsubst %.sh,%,$@) -c ./$< -j n -o $(patsubst %.sh,%.out,$<) -e $(patsubst %.sh,%.error,$<) -t "4:00:00" -p n  

%.out %.error : %X.sh
	qsub $<

clean : 
	rm -rf *.fits sources.txt sources* *.out *.error *.sh params
