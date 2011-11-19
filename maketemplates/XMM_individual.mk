include $(RAWBASEDIR)/maketemplates/master.mk

GZMOS1=pps/*M1*EVL*.FTZ
GZMOS2=pps/*M2*EVL*.FTZ
GZPN=pps/*M2*EVL*.FTZ

all : $(GZMOS1) $(GZMOS2) $(GZPN)

mos1.fits : $(GZMOS1)
	gzcat $^ > $@

mos2.fits : $(GZMOS2)
	gzcat $^ > $@

pn.fits : $(GZPN)
	gzcat $^ > $@

clean :
	rm -f *.fits
