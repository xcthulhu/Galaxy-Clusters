include $(RAWBASEDIR)/maketemplates/master.mk

.PHONY: repro all

all : 
	- make sources.txt

sources.txt : science/sources.txt
	[ -f $< ] && ln -sf $< $@ && echo $@

master_sources.txt : $(BASEDIR)/Data/science-master-clusters/chandra_lookup.tsv
	make -C $(dir $<)/$(shell grep [^0-9]$(notdir $(CURDIR))$$ $< | cut -f1) sources.txt
	[ -f $(dir $<)/$(shell grep [^0-9]$(notdir $(CURDIR))$$ $< | cut -f1)/sources.txt ] && ln -s $(dir $<)/$(shell grep [^0-9]$(notdir $(CURDIR))$$ $< | cut -f1)/sources.txt $@ && touch $@

# Rules for creating & linking the evt2 file
science/sources.txt : science/Makefile
	$(MAKE) -C $(dir $@) $(notdir $@)

work/Makefile : work
	echo RAWBASEDIR=$(RAWBASEDIR)/.. > $@
	echo include '$$(RAWBASEDIR)'/maketemplates/chandra_work.mk >> $@

work/repro : work/Makefile
	make -C work repro
	touch $@

science : 
	mkdir $@

science/Makefile : work/repro science
	echo RAWBASEDIR=$(RAWBASEDIR)/.. > $@
	echo EVT2=$(patsubst work/%,%,$(wildcard work/*_repro_evt2.fits)) >> $@
	echo include '$$(RAWBASEDIR)'/maketemplates/chandra_science.mk >> $@

science/% : science science/Makefile
	make -C $< $(notdir $@)

work :
	mkdir -p $@
	touch work
