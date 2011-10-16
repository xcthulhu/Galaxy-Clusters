include $(RAWBASEDIR)/maketemplates/master.mk
CIAODIR=/usr/local/ciao-4.3/bin
CIAO_INIT=source $(CIAODIR)/ciao.bash
RADIUS=$(shell $(PYTHON) $(BASEDIR)/bin/get_master_radius.py)
NEDARCHIVE=$(shell echo $(RAWBASEDIR)/Data/nedshifts/$(notdir $(shell pwd))R$(RADIUS).tsv)
CHANDRA_OBSIDS=$(shell grep chandra $(notdir $(shell pwd)).tsv | cut -f 4) 
XMM_OBSIDS=$(shell grep XMM $(notdir $(shell pwd)).tsv | cut -f 4) 

ifneq ($(strip $(CHANDRA_OBSIDS)),)
	CHANDRA_MAKE=chandra/Makefile
endif

ifneq ($(strip $(XMM_OBSIDS)),)
	XMM_MAKE=XMM/Makefile
endif

.PHONY: all clean

.PRECIOUS: chandra XMM $(BASEDIR)/Data/nedshifts $(RAWBASEDIR)/Data/nedshifts/%.tsv 

all : $(CHANDRA_MAKE) $(XMM_MAKE) nedshifts.tsv

chandra : 
	mkdir $@

XMM : 
	mkdir $@

# Rule for making $(NEDARCHIVE) ; "$(NEDARCHIVE):" doesn't work
# >>>FUCKING COLONS<<<
$(NEDARCHIVE) :
	$(MAKE) -C $(dir $@) $(notdir $@)

nedshifts.tsv : $(NEDARCHIVE)
	ln -sf $< $@

%/Makefile : %
	echo 'RAWBASEDIR=$(RAWBASEDIR)/..' > $@
	echo 'SATELLITE=$<' >> $@
	echo 'OBSIDS=$(shell grep $< $(notdir $(shell pwd)).tsv | cut -f 4)' >> $@
	echo include '$$(RAWBASEDIR)'/maketemplates/$<_analyze.mk >> $@


clean :
	rm -rf chandra XMM nedshifts.tsv

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
