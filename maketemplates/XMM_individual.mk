include $(RAWBASEDIR)/maketemplates/master.mk

GZMOS1=pps/*M1*EVL*.FTZ
GZMOS2=pps/*M2*EVL*.FTZ
GZPN=pps/*M2*EVL*.FTZ

all : work/Makefile odf/Makefile
	$(MAKE) -C work

work : 
	mkdir $@

work/Makefile : work
	echo RAWBASEDIR=$(RAWBASEDIR)/.. > $@
	echo include '$$(RAWBASEDIR)/maketemplates/XMM_work.mk' >> $@

work/sources.txt : work/Makefile
	make -C work sources.txt

odf/Makefile :
	echo RAWBASEDIR=$(RAWBASEDIR)/.. > $@
	echo include '$$(RAWBASEDIR)/maketemplates/XMM_odf.mk' >> $@

clean :
	rm -f *.fits
	rm -rf work
	make -C odf clean
