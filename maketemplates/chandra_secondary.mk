include $(RAWBASEDIR)/maketemplates/master.mk
.PHONY : all clean reprocess repro-clean

all : 

decompress :
	@for i in *.fits.gz ; do \
		if [ -f $$i ] ; then \
			echo gunzip -f $$i ; \
			gunzip -f $$i ; \
		fi \
	done

# Make symbolic links to primary upon demanded
%.fits :
	@if [ -f ../primary/$@ ] && [ ! -f $@ ]; then \
		echo cp -f ../primary/$@ $@ ; \
		cp -f ../primary/$@ $@ ; \
	fi

repro-clean :
	rm -f *repro*.fits *dsk*evt1.fits *evt1a.fits *reset*.fits

clean : 
	@for i in *.fits ; do \
		if [ -f ../primary/$$i ] && [ -f $$i ] ; then echo "rm $$i" && rm $$i ; fi ; \
	done
