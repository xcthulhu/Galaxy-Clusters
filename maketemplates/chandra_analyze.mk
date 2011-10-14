include $(RAWBASEDIR)/maketemplates/master.mk
CIAODIR=/usr/local/ciao-4.3/bin
CIAO_INIT=source $(CIAODIR)/ciao.bash
OBSDIR=$(RAWBASEDIR)/chandra-obs

.PHONY : all clean Makefile
.PRECIOUS: $(CHANDRA_OBSDIR) $(CHANDRA_OBSDIR)/%

all : $(OBSIDS)

clean :
	rm -f $(OBSIDS)

$(CHANDRA_OBSDIR)/Makefile :
	$(MAKE) -C $(dir $(CHANDRA_OBSDIR)) $(notdir $(CHANDRA_OBSDIR))/$(notdir $@)

$(CHANDRA_OBSDIR)/% : $(CHANDRA_OBSDIR)/Makefile
	@echo ">>> Dowloading Chandra ObsId $(notdir $@) <<<"
	cd $(dir $@) && \
	$(CIAO_INIT) && \
	download_chandra_obsid $(notdir $@)

%: $(CHANDRA_OBSDIR)/% 
	@echo ">>> Linking Chandra ObsId $(notdir $@) <<<"
	ln -s $< $@
