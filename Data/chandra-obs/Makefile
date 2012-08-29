RAWBASEDIR=../..
include $(RAWBASEDIR)/maketemplates/master.mk
.SECONDARY:
.PHONY : all

all : 

all-% : 
	find . -maxdepth 1 -name "[0-9]*" -type d -exec make -C '{}' $(patsubst all-%,%,$@) \;

science-% : 
	find . -maxdepth 1 -name "[0-9]*" -type d -exec make -C '{}' science/$(patsubst science-%,%,$@) \;

%/work/repro : %/work/Makefile
	make -C $(dir $<) repro

%/work/Makefile : %/Makefile
	make -C $(dir $<) work/Makefile

%/Makefile : %
	echo 'RAWBASEDIR=$(RAWBASEDIR)/..' > $@
	echo include '$$(RAWBASEDIR)'/maketemplates/chandra_individual.mk >> $@

0% 1% 2% 3% 4% 5% 6% 7% 8% 9% :
	$(CIAO_INIT) && download_chandra_obsid $@
	@ if [ ! -d $@ ] ; then \
		echo "DOWNLOAD UNSUCCESSFUL - CREATING DUMMY DIRECTORY $@" ; \
		echo mkdir $@ ; \
		mkdir $@ ; \
		echo "CREATING DUMMY MAKEFILE $@/Makefile" ; \
		echo "all : " > $@/Makefile ; \
		echo "%.txt : " >> $@/Makefile ; \
		echo '	touch $$@' >> $@/Makefile ; \
	fi
