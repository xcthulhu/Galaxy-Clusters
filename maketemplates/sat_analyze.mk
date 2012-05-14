include $(RAWBASEDIR)/maketemplates/master.mk
OBSDIR=$(RAWBASEDIR)/Data/$(SATELLITE)-obs

.PHONY : all %-all clean
.PRECIOUS : $(OBSDIR) $(OBSDIR)/%

all : $(OBSIDS) $(patsubst %,%-all,$(OBSIDS))

%-all : %
	@if [ -d $(OBSDIR)/$< ] ; then \
		echo $(MAKE) -C $(OBSDIR) $</Makefile ; \
		$(MAKE) -C $(OBSDIR) $</Makefile ; \
		echo $(MAKE) -C $< all ; \
		$(MAKE) -C $< all ; \
	fi

%-Makefile : %
	$(MAKE) -C $(OBSDIR) $</Makefile

clean :
	rm -f $(OBSIDS)

$(OBSDIR)/% :
	- $(MAKE) -C $(OBSDIR) $(patsubst $(OBSDIR)/%,%,$@)
	- $(MAKE) -C $(OBSDIR) $(patsubst $(OBSDIR)/%,%/Makefile,$@)

%: $(OBSDIR)/% 
	@if [ -d $< ] ; then \
		echo ">>> LINKING - $(SATELLITE) ObsId $(notdir $@) <<<" ; \
		echo ln -fs "$<" "$@" ; \
		ln -fs $< $@ ; \
	else \
		echo ">>> NOT LINKING - $< does not exist <<<" ; \
		echo ">>> LINKING empty directory instead <<<" ; \
		echo ln -fs $(OBSDIR)/empty "$@" ; \
		ln -fs $(OBSDIR)/empty "$@" ; \
	fi
