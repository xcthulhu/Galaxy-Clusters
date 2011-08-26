CIAODIR=/usr/local/ciao-4.3/bin
CIAO_INIT=source $(CIAODIR)/ciao.bash

all : $(SOURCES)

%_chips : %_evt2.fits
	for i in `seq 0 15` ; do  \
		$(CIAO_INIT) && ( ( [ `dmstat "$<[ccd_id=$$i]" | grep max | grep -v '(' | cut -f2 | uniq` = "0" ] && [ `dmstat "$<[ccd_id=$$i]" | grep min | grep -v '(' | cut -f2 | uniq` = "0" ] ) || echo $$i >> $@ ) ; \
	done

%_srcs.reg : %_evt2.fits %_chips
	for i in `cat $(shell echo $< | sed 's/evt2.fits$$/chips/')` ; do \
		$(CIAO_INIT) && dmcopy "$<[ccd_id=$$i][bin sky=1]" CCD$$i-$< ; \
		$(CIAO_INIT) && wavdetect infile="CCD$$i-$<" outfile=CCD$$i-$@.fits scellfile=scell-CCD$i-$@.fits imagefile=imagefile-CCD$$i-$@.fits defnbkgfile=nbgd-CCD$$i-$@.fits regfile=CCD$$i-$@.reg scales="2.0 4.0" clobber=yes ; \
		cat CCD$$i-$@.reg >> $@ ; \
	done


clean : 
	rm -f *_srcs.reg *_chips CCD*.fits scell-CCD*.fits imagefile-CCD*.fits nbgd-CCD*.fits CCD*.reg
