include $(RAWBASEDIR)/maketemplates/master.mk
XMM_OBSDIR=$(RAWBASEDIR)/Data/XMM-obs

.PHONY : all clean Makefile
.PRECIOUS: $(XMM_OBSDIR) $(XMM_OBSDIR)/%

all : $(OBSIDS)

clean :
	rm -f $(OBSIDS)

$(XMM_OBSDIR)/% :
	$(MAKE) -C $(XMM_OBSDIR) $(notdir $@)

%: $(XMM_OBSDIR)/% 
	@echo ">>> Linking XMM ObsId $(notdir $@) <<<"
	ln -s $< $@
