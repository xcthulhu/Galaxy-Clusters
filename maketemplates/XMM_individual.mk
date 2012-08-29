include $(RAWBASEDIR)/maketemplates/master.mk

all : work/Makefile odf/Makefile science/Makefile
	$(MAKE) -C work
	$(MAKE) -C science all

master_sources.txt : $(BASEDIR)/Data/science-master-clusters/XMM_lookup.tsv
	make -C $(dir $<)/$(shell grep [^0-9]$(notdir $(CURDIR))$$ $< | cut -f1) sources.txt
	[ -f $(dir $<)/$(shell grep [^0-9]$(notdir $(CURDIR))$$ $< | cut -f1)/sources.txt ] && ln -s $(dir $<)/$(shell grep [^0-9]$(notdir $(CURDIR))$$ $< | cut -f1)/sources.txt $@ && touch $@

work science : 
	mkdir $@

work/Makefile : work
	echo RAWBASEDIR=$(RAWBASEDIR)/.. > $@
	echo include '$$(RAWBASEDIR)/maketemplates/XMM_work.mk' >> $@

work/emchain work/epchain : work/Makefile
	make -C $(dir $@) $(notdir $@)
	touch $@

science/Makefile : work/emchain work/epchain science
	echo RAWBASEDIR=$(RAWBASEDIR)/.. > $@
	echo EVL=$(shell ls work/*M1*MIEVL* | sed -e 's/work\//MOS1/g') $(shell ls work/*M2*MIEVL* | sed -e 's/work\//MOS2/g') $(shell ls work/*PN*PIEVL* | sed -e 's/work\//PN/g') >> $@
	echo include '$$(RAWBASEDIR)/maketemplates/XMM_science.mk' >> $@

science/sources.txt : science/Makefile
	- make -C $(dir $@) $(notdir $@)

sources.sh : work/Makefile
	echo '#!/bin/bash' > $@
	echo 'export LD_LIBRARY_PATH=${HOME}/lib:${HOME}/lib64' >> $@
	echo "make -C $(CURDIR) sources.txt" >> $@
	chmod +x $@

sources-%.sh : sources.sh
	beo-gensge.pl -N $(patsubst %.sh,%,$@) -c ./$< -j n -o sources.out -e sources.error -t "4:00:00" -p n

sources.out sources.error : sources-$(notdir $(CURDIR)).sh
	qsub $<

sources.txt : science/sources.txt
	[ -f $< ] && ln -s $< $@

odf/Makefile :
	echo RAWBASEDIR=$(RAWBASEDIR)/.. > $@
	echo include '$$(RAWBASEDIR)/maketemplates/XMM_odf.mk' >> $@

clean : odf/Makefile
	rm -f *.fits
	rm -rf work science sources*
	make -C odf clean
