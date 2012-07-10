include $(RAWBASEDIR)/maketemplates/master.mk

.PHONY: repro all

all : 
	- make sources.txt

sources.txt : work/sources.txt
	[ -f $< ] && ln -s $< $@

# Rules for creating & linking the evt2 file
work/sources.txt : work/Makefile
	- $(MAKE) -C $(dir $@) $(notdir $@)

work/Makefile : work
	echo RAWBASEDIR=$(RAWBASEDIR)/.. > $@
	echo include '$$(RAWBASEDIR)'/maketemplates/chandra_work.mk >> $@
	@ if [ -f work/sources.txt ] ; then echo touch work/sources.txt ; touch work/sources.txt ; fi

repro : work/Makefile
	- make -C work repro

work :
	mkdir -p $@
	touch work
