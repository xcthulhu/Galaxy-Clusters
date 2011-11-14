include $(RAWBASEDIR)/maketemplates/master.mk

all : 

% :
	mkdir $@
	echo 'RAWBASEDIR=$(RAWBASEDIR)/..' > $@/Makefile
	echo include '$$(RAWBASEDIR)'/maketemplates/HST_individual.mk >> $@/Makefile
