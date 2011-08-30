CIAODIR=/usr/local/ciao-4.3/bin
CIAO_INIT=source $(CIAODIR)/ciao.bash
BASEDIR=../..

all : chandra XMM

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

clean :
	rm -rf chandra XMM

