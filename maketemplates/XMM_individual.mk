include $(RAWBASEDIR)/maketemplates/master.mk

GZMOS1=pps/*M1*EVL*.FTZ
GZMOS2=pps/*M2*EVL*.FTZ
GZPN=pps/*M2*EVL*.FTZ

all : work/Makefile odf/Makefile

work : 
	mkdir $@

work/Makefile : work
	echo RAWBASEDIR=$(RAWBASEDIR)/.. > $@
	echo include '$$(RAWBASEDIR)/maketemplates/XMM_work.mk' >> $@

odf/Makefile :
	echo RAWBASEDIR=$(RAWBASEDIR)/.. > $@
	echo include '$$(RAWBASEDIR)/maketemplates/XMM_odf.mk' >> $@

clean :
	rm -f *.fits
	make -C odf clean
