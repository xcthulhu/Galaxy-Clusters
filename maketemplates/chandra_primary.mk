include $(RAWBASEDIR)/maketemplates/master.mk
.PHONY : all clean reprocess
OBSID=$(shell basename $(dir $(shell pwd)))

all : evt2.fits 

decompress :
	@for i in *.fits.gz ; do \
		if [ -f $$i ] ; then \
			echo gunzip -f $$i ; \
			gunzip -f $$i ; \
		fi \
	done

../secondary/Makefile :
	$(MAKE) -C .. secondary/Makefile

evt2.fits : ../secondary/Makefile
	$(MAKE) decompress
	$(MAKE) -C ../secondary decompress
	
	@for i in *.fits ; do \
		[ -f $$i ] && echo "$(MAKE) -B -C ../secondary $$i" && $(MAKE) -B -C ../secondary $$i ; \
	done

	$(MAKE) -C ../secondary repro-clean

	$(CIAO_INIT) && chandra_repro indir=../secondary outdir=. clobber=yes

	@if [ -f $(shell ls -t *evt2.fits | head -1) ] ; then \
		echo ">>> Linking" $(shell ls -t *evt2.fits | head -1) to $@ "<<<" ; \
		echo ln -sf $(shell ls -t *evt2.fits | head -1) $@ ; \
		ln -sf $(shell ls -t *evt2.fits | head -1) $@ ; \
	else \
		echo "COULD NOT LINK ANYTHING TO $@ !" ; \
	fi
	
clean : 
	rm -f evt2.fits
