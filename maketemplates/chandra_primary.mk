include $(RAWBASEDIR)/maketemplates/master.mk
.PHONY : all clean

all : evt2.fits 

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
