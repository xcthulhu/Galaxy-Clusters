include $(RAWBASEDIR)/maketemplates/master.mk
RADIUS=$(shell $(PYTHON) $(BASEDIR)/bin/get_master_radius.py)
NEDARCHIVE=$(shell echo $(RAWBASEDIR)/Data/nedshifts/$(notdir $(shell pwd))R$(RADIUS).tsv)
CHANDRA_OBSIDS=$(shell grep chandra $(notdir $(shell pwd)).tsv | cut -f 4) 
XMM_OBSIDS=$(shell grep XMM $(notdir $(shell pwd)).tsv | cut -f 4) 

ifneq ($(strip $(CHANDRA_OBSIDS)),)
	CHANDRA_MAKE=chandra/Makefile
	CHANDRA_DOWNLOAD=chandra/download
endif

ifneq ($(strip $(XMM_OBSIDS)),)
	XMM_MAKE=XMM/Makefile
	XMM_DOWNLOAD=XMM/download
endif

.PHONY: all clean
.PRECIOUS: chandra XMM $(BASEDIR)/Data/nedshifts $(RAWBASEDIR)/Data/nedshifts/%.tsv 
.DELETE_ON_ERROR: sources.txt unclustered_sources.txt

all : $(CHANDRA_MAKE) $(XMM_MAKE) nedshifts.tsv sources.txt

ifneq ($(strip $(CHANDRA_OBSIDS)),)
repro : chandra/Makefile
	make -C chandra repro
else
repro : 
endif

chandra : 
	mkdir $@

XMM : 
	mkdir $@

unclustered_sources.txt : chandra/sources.txt XMM/sources.txt
	touch $^
	cat $^ | sort | uniq > $@ && touch $@

sources.txt : unclustered_sources.txt 
	touch $^
	$(PYTHON) $(BIN)/cluster_srcs.py $(SOURCE_CLSTR_ARCSECS) $< > $@ && touch $@

%/sources.txt : % %/Makefile
	make -C $< sources.txt 
	[ -f $@ ] && touch $@

sources.sh : $(EVT2)
	echo '#!/bin/bash' > $@
	echo 'export LD_LIBRARY_PATH=${HOME}/lib:${HOME}/lib64' >> $@
	echo "make -C $(CURDIR) sources.txt" >> $@
	chmod +x $@

%X.sh : %.sh
	beo-gensge.pl -N $(patsubst %.sh,%,$@) -c ./$< -j n -o $(patsubst %.sh,%.out,$<) -e $(patsubst %.sh,%.error,$<) -t "4:00:00" -p n  

%.out %.error : %X.sh
	qsub $<

# Rule for making $(NEDARCHIVE) ; "$(NEDARCHIVE):" doesn't work
$(NEDARCHIVE) :
	$(MAKE) -C $(dir $@) $(notdir $@)

download : $(CHANDRA_DOWNLOAD) $(XMM_DOWNLOAD)
	touch $@

%/download : % %/Makefile
	make -C $< download

nedshifts.tsv : $(NEDARCHIVE)
	ln -sf $< $@

$(RAWBASEDIR)/Data/HST-obs/$(notdir $(shell pwd)) :
	make -C $(BASEDIR)/Data/HST-obs/ $(notdir $@)

hst : $(RAWBASEDIR)/Data/HST-obs/$(notdir $(shell pwd))
	ln -sf $< $@

%/Makefile : %
	echo 'RAWBASEDIR=$(RAWBASEDIR)/..' > $@
	echo 'SATELLITE=$<' >> $@
	echo 'OBSIDS=$(shell grep $< $(notdir $(shell pwd)).tsv | cut -f 4)' >> $@
	echo include '$$(RAWBASEDIR)'/maketemplates/sat_analyze.mk >> $@

clean :
	rm -rf chandra XMM nedshifts.tsv *sources* download
