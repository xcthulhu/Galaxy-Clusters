include $(RAWBASEDIR)/maketemplates/master.mk
.PHONY : all clean reprocess

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
	@if [ -f ../primary/$@ ] ; then \
		echo cp -f ../primary/$@ $@ ; \
		cp -f ../primary/$@ $@ ; \
	fi

repro-clean :
	rm -f *repro*.fits *dsk*evt1.fits	

clean : repro-clean
	@for i in *.fits ; do \
		[ -f ../primary/$$i ] && echo "rm $$i" && rm $$i ; \
	done
