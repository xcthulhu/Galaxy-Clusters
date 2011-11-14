include $(RAWBASEDIR)/maketemplates/master.mk

# BUG: The wide field lens archival images are messed up
# BIGGER BUG: We spent $10 billion on Hubble, yet have $15 trillion in debt...
all : $(WFPC2) $(WFC3) $(ACS) #$(WFPC) 

%.fits :
	-wget "http://archive.eso.org/archive/hst/proxy/ecfproxy?file_id=$(patsubst %.fits,%,$@)" -O $@
	if [ ! -s $@ ] ; then echo ">>>" Retrieval of $@ FAILED\! ...DELETING "<<<"; echo rm -f $@ ; rm -f $@ ; fi

clean :
	rm -f $(WFPC) $(WFPC2) $(WFC3) $(ACS)
