include $(RAWBASEDIR)/maketemplates/master.mk
CIAODIR=/usr/local/ciao-4.3/bin
CIAO_INIT=source $(CIAODIR)/ciao.bash
CHANDRA_OBSDIR=$(RAWBASEDIR)/Data/chandra-obs
OBSID_MAKES=$(patsubst %, %/Makefile, $(OBSIDS))

.PHONY : all clean Makefile
.PRECIOUS: $(CHANDRA_OBSDIR) $(CHANDRA_OBSDIR)/%

all :  $(OBSIDS) $(OBSID_MAKES)

clean :
	rm -f $(OBSIDS)

%/Makefile :
	$(MAKE) -C $(CHANDRA_OBSDIR) $@
	$(MAKE) $(patsubst %/Makefile,%,$@)

$(CHANDRA_OBSDIR)/% :
	$(MAKE) -C $(CHANDRA_OBSDIR) $(patsubst $(CHANDRA_OBSDIR)/%,%,$@)

%: $(CHANDRA_OBSDIR)/% 
	@echo ">>> Linking Chandra ObsId $(notdir $@) <<<"
	ln -s $< $@
