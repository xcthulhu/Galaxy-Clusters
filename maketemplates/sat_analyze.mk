include $(RAWBASEDIR)/maketemplates/master.mk
OBSDIR=$(RAWBASEDIR)/Data/$(SATELLITE)-obs

.PHONY : all %-all clean
.PRECIOUS : $(OBSDIR) $(OBSDIR)/%

all : $(OBSIDS) $(patsubst %,%-all,$(OBSIDS))

%-all : %
	$(MAKE) -C $< all

clean :
	rm -f $(OBSIDS)

$(OBSDIR)/% :
	$(MAKE) -C $(OBSDIR) $(patsubst $(OBSDIR)/%,%/Makefile,$@)

%: $(OBSDIR)/% 
	@if [ -d $< ] ; then \
		echo ">>> LINKING - $(SATELLITE) ObsId $(notdir $@) <<<" ; \
		echo ln -fs "$<" "$@" ; \
		ln -fs $< $@ ; \
	else \
		echo ">>> NOT LINKING - $< does not exist <<<" ; \
	fi
