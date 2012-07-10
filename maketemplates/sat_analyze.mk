include $(RAWBASEDIR)/maketemplates/master.mk
OBSDIR=$(RAWBASEDIR)/Data/$(SATELLITE)-obs

.PHONY : all %-all clean
.PRECIOUS : $(OBSDIR) $(OBSDIR)/%
.DELETE_ON_ERROR : sources.txt

all : $(OBSIDS) $(patsubst %,%-all,$(OBSIDS)) sources.txt

sources.txt : $(patsubst %,%/sources.txt,$(OBSIDS))
	cat $(patsubst %,%/sources.txt,$(OBSIDS)) > $@

%/sources.txt : % %/Makefile 
	make -C $< sources.txt

%/Makefile : %
	$(MAKE) -C $(OBSDIR) $</Makefile

clean :
	rm -f $(OBSIDS)

$(OBSIDS): 
	- $(MAKE) -C $(OBSDIR) $@
	@if [ -d $< ] ; then \
		echo ">>> LINKING - $(SATELLITE) ObsId $(notdir $@) <<<" ; \
		echo ln -fs $(OBSDIR)/$@ $@ ; \
		ln -fs $(OBSDIR)/$@ $@ ; \
	else \
		echo ">>> NOT LINKING - $< does not exist <<<" ; \
		echo ">>> LINKING empty directory instead <<<" ; \
		echo ln -fs $(OBSDIR)/empty "$@" ; \
		ln -fs $(OBSDIR)/empty "$@" ; \
	fi
