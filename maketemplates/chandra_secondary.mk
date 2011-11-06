include $(RAWBASEDIR)/maketemplates/master.mk
.PHONY : all clean reprocess

all : evt2.fits 

evt1.fits : 
	@if [ -f *evt1*.fits.gz ] ; then \
		echo ">>> Unzipping " *evt1*.fits.gz to $@ "<<<" ; \
		echo gunzip *evt1*.fits.gz ; \
		gunzip *evt1*.fits.gz ; \
	fi

	@if [ -f *evt1*.fits ] ; then \
		echo ">>> Linking" *evt1*.fits to $@ "<<<" ; \
		echo ln -sf *evt1*.fits $@ ; \
		ln -sf *evt1*.fits $@ ; \
	fi

# Rules for making the evt2.fits file
evt2.fits : 
	@if [ -f *evt2*.fits.gz ] ; then \
		echo ">>> Unzipping " *evt2*.fits.gz to $@ "<<<" ; \
		echo gunzip *evt2*.fits.gz ; \
		gunzip *evt2*.fits.gz ; \
	fi

	@if [ -f *evt2*.fits ] ; then \
		echo ">>> Linking" *evt2*.fits to $@ "<<<" ; \
		echo ln -sf *evt2*.fits $@ ; \
		ln -sf *evt2*.fits $@ ; \
	fi

clean :
