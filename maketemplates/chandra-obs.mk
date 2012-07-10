include $(RAWBASEDIR)/maketemplates/master.mk
.PHONY : all

all : 

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
