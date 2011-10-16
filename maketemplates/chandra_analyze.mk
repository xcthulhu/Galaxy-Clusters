include $(RAWBASEDIR)/maketemplates/master.mk
CIAODIR=/usr/local/ciao-4.3/bin
CIAO_INIT=source $(CIAODIR)/ciao.bash
CHANDRA_OBSDIR=$(RAWBASEDIR)/Data/chandra-obs

.PHONY : all clean Makefile
.PRECIOUS: $(CHANDRA_OBSDIR) $(CHANDRA_OBSDIR)/%

all : $(OBSIDS)

clean :
	rm -f $(OBSIDS)

$(CHANDRA_OBSDIR)/% :
	$(MAKE) -C $(CHANDRA_OBSDIR) $(notdir $@)

%: $(CHANDRA_OBSDIR)/% 
	@echo ">>> Linking Chandra ObsId $(notdir $@) <<<"
	ln -s $< $@
