include $(RAWBASEDIR)/maketemplates/master.mk
CIAODIR=/usr/local/ciao-4.3/bin
CIAO_INIT=source $(CIAODIR)/ciao.bash

all : 

%/Makefile : %
	echo 'RAWBASEDIR=$(RAWBASEDIR)/..' > $@
	echo include '$$(RAWBASEDIR)'/maketemplates/chandra_individual.mk >> $@

% :
	$(CIAO_INIT) && download_chandra_obsid $@
