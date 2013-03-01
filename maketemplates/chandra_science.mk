include $(RAWBASEDIR)/maketemplates/master.mk
.SECONDARY : 
.PHONY : all clean bandouts
.DELETE_ON_ERROR : 
OBSID=$(notdir $(patsubst %/,%,$(dir $(CURDIR))))

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
	make sizes
	paste $^ > $@

sizes : 
	@for i in $(patsubst %,sizes-%.txt, $(BANDS)) ; do \
		if [ ! -f $$i ] || [ `wc -l $$i | cut -d' ' -f1` != $(shell wc -l master_sources.txt | cut -d' ' -f1 ) ] ; then \
			echo rm -f $$i ; \
			rm -f $$i ; \
			echo make $$i ; \
			make $$i ; \
		fi ; \
	done
			

sizes-%.txt : master_sources.txt asol.fits
	@if [ ! -f $@ ] || [ `wc -l $@ | cut -d' ' -f1` != $(shell wc -l master_sources.txt | cut -d' ' -f1 ) ] ; then \
		echo rm -f $@ ; \
		rm -f $@ ; \
		$(CIAO_INIT) && while read p ; do \
			echo $(BIN)/psffrac.py $(EVT2) asol.fits `echo $$p | cut -d' ' -f1` `echo $$p | cut -d' ' -f2` $(patsubst sizes-%.txt,%,$@) '>> $@'; \
			$(BIN)/psffrac.py $(EVT2) asol.fits `echo $$p | cut -d' ' -f1` `echo $$p | cut -d' ' -f2` $(patsubst sizes-%.txt,%,$@) >> $@; \
		done < $< ; \
	else \
		echo touch $@ ; \
		touch $@ ; \
	fi

../master_sources.txt : 
	make -C .. master_sources.txt

fluxes : master-sizes.txt
	$(PYTHON) $(BIN)/mkfluxdirs.py $@ $< "$(BANDS)" "$(OCTAVES)"

fluxes/Makefile : fluxes
	echo RAWBASEDIR=$(RAWBASEDIR)/.. > $@
	echo EVT2=$(EVT2) >> $@
	echo include '$$(RAWBASEDIR)'/maketemplates/chandra_fluxes.mk >> $@

fluxp-% : fluxes/Makefile
	make -C fluxes $@

master_sources.txt : ../master_sources.txt
	ln -sf $< $@ && touch $@

$(EVT2) : ../work/$(EVT2)
	ln -sf $< $@
	touch $@

# Create Images
img.fits : $(EVT2)
	$(CIAO_INIT) && dmcopy "$<[ccd_id=0:3][bin sky=1][opt mem=135]" $@ clobber=yes

all-fluxp : $(patsubst %, fluxp-%, $(OCTAVES))

all-fluxesout : $(patsubst %, fluxes-%.out, $(OCTAVES))

$(patsubst %, fluxes-%.sh, $(OCTAVES)) : fluxes/Makefile
	echo '#!/bin/bash' > $@
	echo 'export LD_LIBRARY_PATH=${HOME}/lib:${HOME}/lib64' >> $@
	echo "make -C $(CURDIR) $(patsubst fluxes-%.sh,fluxp-%,$@)" >> $@
	chmod +x $@

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

X$(OBSID)-%.sh : %.sh
	beo-gensge.pl -N "$(CURDIR)/$@" -c ./$< -j n -o $(patsubst %.sh,%.out,$<) -e $(patsubst %.sh,%.error,$<) -t "16:00:00" -p n  

%.out %.error : X$(OBSID)-%.sh
	qsub $(CURDIR)/$<

clean : 
	rm -rf *.fits sources.txt sources* *.out *.error *.sh params
