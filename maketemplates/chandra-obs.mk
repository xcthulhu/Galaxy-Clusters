include $(RAWBASEDIR)/maketemplates/master.mk

all : 

%/Makefile : %
	echo 'RAWBASEDIR=$(RAWBASEDIR)/..' > $@
	echo include '$$(RAWBASEDIR)'/maketemplates/chandra_individual.mk >> $@

% :
	$(CIAO_INIT) && download_chandra_obsid $@
