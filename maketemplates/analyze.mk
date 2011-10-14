CIAODIR=/usr/local/ciao-4.3/bin
CIAO_INIT=source $(CIAODIR)/ciao.bash
include $(BASEDIR)/python_logic.mk
COORDS=$(shell basename `pwd` | sed -e 's/+/ +/' | sed -e 's/-/ -/')
RADIUS=$(shell $(PYTHON) $(BASEDIR)/get_master_radius.py)
NEDARCHIVE="$(BASEDIR)/nedshifts/$(shell basename `pwd`)_$(RADIUS).tsv"

all : chandra XMM nedshifts.tsv

chandra : *.tsv
	[ -d $@ ] || mkdir $@
	for i in `grep $@ $< | cut -f 4` ; do \
		if [ ! -d "$(BASEDIR)/$@-obs/$$i" ] ; then \
			echo ">>> Downloading $@ ObsId $$i <<<" ; \
			$(CIAO_INIT) && download_chandra_obsid $$i ; \
			[ -d "$(BASEDIR)/$@-obs/" ] || mkdir "$(BASEDIR)/$@-obs" ; \
			mv $$i "$(BASEDIR)/$@-obs/" ; \
		fi ; \
		echo ">>> Linking $@ ObsId $$i <<<" ; \
		ln -s ../$(BASEDIR)/$@-obs/$$i $@ ; \
	done
	$(BASEDIR)/make_$@_makes.sh $@

XMM : *.tsv
	[ -d $@ ] || mkdir $@
	for i in `grep $@ $< | cut -f 4` ; do \
		if [ ! -d "$(BASEDIR)/$@-obs/$$i" ] ; then \
			echo ">>> Downloading $@ ObsId $$i <<<" ; \
			./get_XMM_obs.sh $$i ; \
			[ -d "$(BASEDIR)/$@-obs/" ] || mkdir "$(BASEDIR)/$@-obs" ; \
			[ -d $$i ] && mv $$i "$(BASEDIR)/$@-obs/" ; \
		fi ; \
		if [ -d $(BASEDIR)/$@-obs/$$i ] ; then \
			echo ">>> Linking $@ ObsId $$i <<<" ; \
			ln -s ../$(BASEDIR)/$@-obs/$$i $@ ; \
		else \
			echo ">>> DID NOT MANAGE TO DOWNLOAD XMM OBSID $$i <<<" ; \
		fi ; \
	done

nedshifts.tsv :
	[ -d $(shell dirname $(NEDARCHIVE)) ] || mkdir -p $(shell dirname $(NEDARCHIVE))
	[ -e $(NEDARCHIVE) ] || $(PYTHON) $(BASEDIR)/get_ned.py $(COORDS) > $(NEDARCHIVE)
	[ -e $@ ] || ln -s $(NEDARCHIVE) $@

clean :
	rm -rf chandra XMM nedshifts.tsv
