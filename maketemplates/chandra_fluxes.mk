include $(RAWBASEDIR)/maketemplates/master.mk
.SECONDARY : 
.PHONY : all clean
.DELETE_ON_ERROR : 

all : 

makes : 
	@find -type d -name "*_*_*_*" | \
	while read dir; do \
		[ -f $$dir/Makefile ] || make $$dir/Makefile ; \
	done	

fluxp : $(patsubst %, fluxp-%, $(OCTAVES))

fluxp-% : 
	@if [ -e "$@.out" ] && [ "$(shell wc -l ../master_sources.txt | cut -d' ' -f1)" -eq "`wc -l $@.out | cut -d' ' -f1`" ] ; then \
		echo "Done with $@" ; \
	else \
		touch $@.out ; \
		for i in *_*_*_$(shell python -c "print ($(shell echo $@ | cut -d'-' -f2) + $(shell echo $@ | cut -d'-' -f3)) / 2.0") ; do \
			if [ -z "`grep $$i $@.out`" ] ; then \
				echo "Making $$i" ; \
				make $$i/Makefile ; \
				make -C $$i fluxes ; \
				echo $$i >> $@.out ; \
			else \
				echo "Skipping $$i" ; \
			fi ; \
		done ; \
	fi

%/Makefile :
	echo RAWBASEDIR=$(RAWBASEDIR)/.. > $@
	echo EVT2=$(EVT2) >> $@
	echo RA=$(shell dirname $@ | cut -d_ -f1) >> $@
	echo DEC=$(shell dirname $@ | cut -d_ -f2) >> $@
	echo RADIUS=$(shell dirname $@ | cut -d_ -f3) >> $@
	echo MY_OCTAVES=$(shell $(PYTHON) $(BIN)/get_octaves.py $(shell dirname $@ | cut -d_ -f4) $(OCTAVES)) >> $@
	echo include '$$(RAWBASEDIR)'/maketemplates/chandra_individual_fluxes.mk >> $@

clean : 
	rm -fr *_*_*_*/*
