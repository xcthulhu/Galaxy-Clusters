include $(RAWBASEDIR)/maketemplates/master.mk
OBSDIR=$(RAWBASEDIR)/Data/$(SATELLITE)-obs

.PHONY : all %-all clean
.SECONDARY :
.PRECIOUS : $(OBSDIR) $(OBSDIR)/%
.DELETE_ON_ERROR : sources.txt download $(OBSID)

all : sources.txt

unclustered_sources.txt : $(patsubst %,%/sources.txt,$(OBSIDS))
	cat [0-9]*/sources.txt | sort | uniq > $@

sources.txt : unclustered_sources.txt
	$(PYTHON) $(BIN)/cluster_srcs.py $(SOURCE_CLSTR_ARCSECS) $< > $@

%/sources.txt : % %/Makefile 
	- make -C $< sources.txt

%/Makefile : %
	$(MAKE) -C $(OBSDIR) $</Makefile

clean :
	rm -f $(OBSIDS) download *.txt

download : $(OBSIDS)
	touch $@

$(OBSIDS): 
	- rm -f $@
	- $(MAKE) -C $(OBSDIR) $@
	@if [ -d $(OBSDIR)/$@ ] ; then \
		echo ">>> LINKING - $(SATELLITE) ObsId $(notdir $@) <<<" ; \
		echo ln -fs $(OBSDIR)/$@ $@ ; \
		ln -fs $(OBSDIR)/$@ $@ ; \
	else \
		echo ">>> NOT LINKING - $(OBSDIR)/$@ does not exist <<<" ; \
		echo ">>> LINKING empty directory instead <<<" ; \
		echo ln -fs $(OBSDIR)/empty "$@" ; \
		ln -fs $(OBSDIR)/empty "$@" ; \
	fi
