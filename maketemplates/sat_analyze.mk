include $(RAWBASEDIR)/maketemplates/master.mk
XMM_OBSDIR=$(RAWBASEDIR)/Data/XMM-obs
OBSID_MAKES=$(patsubst %, %/Makefile, $(OBSIDS))

.PHONY : all clean
.PRECIOUS : $(XMM_OBSDIR) $(XMM_OBSDIR)/%

all : $(OBSIDS) $(OBSID_MAKES)

%/Makefile :
	$(MAKE) -C $(XMM_OBSDIR) $@
	$(MAKE) $(patsubst %/Makefile,%,$@)

clean :
	rm -f $(OBSIDS)

$(XMM_OBSDIR)/% :
	$(MAKE) -C $(XMM_OBSDIR) $(patsubst $(XMM_OBSDIR)/%,%,$@) 

%: $(XMM_OBSDIR)/% 
	@echo ">>> Linking XMM ObsId $(notdir $@) <<<"
	ln -fs $< $@
