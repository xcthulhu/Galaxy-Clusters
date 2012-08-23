include $(RAWBASEDIR)/maketemplates/master.mk
.SECONDARY:
.PHONY : all

all : 

makes : 
	for i in $(shell ls -d [0-9]*) ; do \
		echo make $$i/Makefile ; \
		make $$i/Makefile ; \
	done

repros : 
	for i in $(shell ls -d [0-9]*) ; do \
		echo make $$i/work/repro ; \
		make $$i/work/repro ; \
	done

%/work/repro : %/work/Makefile
	make -C $(dir $<) repro

%/work/Makefile : %/Makefile
	make -C $(dir $<) work/Makefile

%/Makefile : %
	echo 'RAWBASEDIR=$(RAWBASEDIR)/..' > $@
	echo include '$$(RAWBASEDIR)'/maketemplates/chandra_individual.mk >> $@

% :
	$(CIAO_INIT) && download_chandra_obsid $@
	@ if [ ! -d $@ ] ; then \
		echo "DOWNLOAD UNSUCCESSFUL - CREATING DUMMY DIRECTORY $@" ; \
		echo mkdir $@ ; \
		mkdir $@ ; \
		echo "CREATING DUMMY MAKEFILE $@/Makefile" ; \
		echo 'RAWBASEDIR=$(RAWBASEDIR)/..' > $@/Makefile ; \
		echo include '$$(RAWBASEDIR)'/maketemplates/dummy_obs.mk >> $@/Makefile ; \
	fi
