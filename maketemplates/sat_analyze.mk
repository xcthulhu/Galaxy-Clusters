include $(RAWBASEDIR)/maketemplates/master.mk
OBSDIR=$(RAWBASEDIR)/Data/$(SATELLITE)-obs

.PHONY : all %-all clean
.PRECIOUS : $(OBSDIR) $(OBSDIR)/%
.DELETE_ON_ERROR : sources.txt download $(OBSID)

all : $(OBSIDS) $(patsubst %,%-all,$(OBSIDS)) sources.txt

sources.txt : $(patsubst %,%/sources.txt,$(OBSIDS))
	cat $(patsubst %,%/sources.txt,$(OBSIDS)) > $@

%/sources.txt : % %/Makefile 
	make -C $< sources.txt

%/Makefile : %
	$(MAKE) -C $(OBSDIR) $</Makefile

clean :
	rm -f $(OBSIDS) download sources.txt

download : $(OBSIDS)
	touch $@

$(OBSIDS): 
	- rm $@
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
