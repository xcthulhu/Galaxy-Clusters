include $(RAWBASEDIR)/maketemplates/master.mk
CIAODIR=/usr/local/ciao-4.3/bin
CIAO_INIT=source $(CIAODIR)/ciao.bash
COORDS=$(shell echo $(basename $(PWD)) | sed -e 's/+/ +/' | sed -e 's/-/ -/')
RADIUS=$(shell $(PYTHON) $(BASEDIR)/bin/get_master_radius.py)
NEDARCHIVE="$(BASEDIR)/nedshifts/$(basename $(PWD))_$(RADIUS).tsv"
CHANDRA_OBSIDS=$(shell grep chandra $(notdir $(PWD)).tsv | cut -f 4) 
XMM_OBSIDS=$(shell grep XMM $(notdir $(PWD)).tsv | cut -f 4) 

ifneq ($(strip $(CHANDRA_OBSIDS)),)
	CHANDRA_MAKE=chandra/Makefile
endif

ifneq ($(strip $(XMM_OBSIDS)),)
	XMM_MAKE=XMM/Makefile
endif

.PRECIOUS: chandra XMM

all : $(CHANDRA_MAKE) $(XMM_MAKE) #nedshifts.tsv

chandra : 
	mkdir $@

XMM : 
	mkdir $@

%/Makefile : %
	echo 'RAWBASEDIR=$(RAWBASEDIR)/..' > $@
	echo 'SATELLITE=$<' >> $@
	echo 'OBSIDS=$(shell grep $< $(notdir $(PWD)).tsv | cut -f 4)' >> $@
	echo include '$$(RAWBASEDIR)'/maketemplates/$<_analyze.mk >> $@

#XMM : *.tsv
#	[ -d $@ ] || mkdir $@
#	for i in `grep $@ $< | cut -f 4` ; do \
#		if [ ! -d "$(BASEDIR)/$@-obs/$$i" ] ; then \
#			echo ">>> Downloading $@ ObsId $$i <<<" ; \
#			./get_XMM_obs.sh $$i ; \
#			[ -d "$(BASEDIR)/$@-obs/" ] || mkdir "$(BASEDIR)/$@-obs" ; \
#			[ -d $$i ] && mv $$i "$(BASEDIR)/$@-obs/" ; \
#		fi ; \
#		if [ -d $(BASEDIR)/$@-obs/$$i ] ; then \
#			echo ">>> Linking $@ ObsId $$i <<<" ; \
#			ln -s ../$(BASEDIR)/$@-obs/$$i $@ ; \
#		else \
#			echo ">>> DID NOT MANAGE TO DOWNLOAD XMM OBSID $$i <<<" ; \
#		fi ; \
#	done

$(BASEDIR)/Data/nedshifts:
	$(MAKE) -C $(BASEDIR)/Data

nedshifts.tsv :
	[ -d $(shell dirname $(NEDARCHIVE)) ] || mkdir -p $(shell dirname $(NEDARCHIVE))
	[ -e $(NEDARCHIVE) ] || $(PYTHON) $(BASEDIR)/get_ned.py $(COORDS) > $(NEDARCHIVE)
	[ -e $@ ] || ln -s $(NEDARCHIVE) $@

clean :
	rm -rf chandra XMM nedshifts.tsv
