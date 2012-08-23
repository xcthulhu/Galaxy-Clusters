include $(RAWBASEDIR)/maketemplates/master.mk

all : work/Makefile odf/Makefile
	$(MAKE) -C work

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
	echo EVL=$(shell ls work/*PN*PIEVL* | sed -e 's/work\//PN/g') $(shell ls work/*M1*MIEVL* | sed -e 's/work\//MOS1/g') $(shell ls work/*M2*MIEVL* | sed -e 's/work\//MOS2/g') >> $@
	echo include '$$(RAWBASEDIR)/maketemplates/XMM_science.mk' >> $@

sources.sh : work/Makefile
	echo '#!/bin/bash' > $@
	echo "make -C $(PWD)/science sources.txt" >> $@
	chmod +x $@

sources-$(notdir $(PWD)).sh : sources.sh
	beo-gensge.pl -N sources-$(notdir $(PWD)) -c ./$< -j n -o sources.out -e sources.error -t "1:00:00" -p n

sources.out sources.error : sources-$(notdir $(PWD)).sh
	qsub $<

#work/sources.txt : work/Makefile
#	make -C work sources.txt

work/sources.txt : sources.out

sources.txt : work/sources.txt
	ln -s $< $@

odf/Makefile :
	echo RAWBASEDIR=$(RAWBASEDIR)/.. > $@
	echo include '$$(RAWBASEDIR)/maketemplates/XMM_odf.mk' >> $@

clean : odf/Makefile
	rm -f *.fits
	rm -rf work science sources*
	make -C odf clean
