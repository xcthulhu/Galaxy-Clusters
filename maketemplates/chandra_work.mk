include $(RAWBASEDIR)/maketemplates/master.mk
.SECONDARY : 
.PHONY : all clean reprocess
.DELETE_ON_ERROR : repro decompress

all : repro

# Reprocessing nonsense :(
decompress :
	@for i in ../primary/*.fits.gz ../secondary/*.fits.gz ; do \
		if [ -f $$i ] ; then \
			echo zcat $$i \> `basename $$i | sed -e 's/.gz//'`; \
			zcat $$i > `basename $$i | sed -e 's/.gz//'`; \
		fi \
	done
	@for i in ../primary/*.fits ../secondary/*.fits ; do \
		if [ -f $$i ] ; then \
			echo cp $$i `basename $$i`; \
			cp $$i `basename $$i`; \
		fi \
	done
	touch $@

asol.fits : decompress
	$(CIAO_INIT) && dmmerge $(wildcard *asol*.fits) $@

aspect : ../secondary/aspect
	ln -s $< $@

ephem : ../secondary/ephem
	ln -s $< $@

repro : decompress aspect ephem
	$(CIAO_PYTHON) $(CHANDRA_REPRO) indir=. outdir=. clobber=yes && touch $@

clean : 
	rm -rf *.fits aspect ephem repro decompress *.lis *.par *.lis_* tmp*
