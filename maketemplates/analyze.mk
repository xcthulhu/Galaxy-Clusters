include $(RAWBASEDIR)/maketemplates/master.mk
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
$(NEDARCHIVE) :
	$(MAKE) -C $(dir $@) $(notdir $@)

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
	rm -rf chandra XMM nedshifts.tsv
