CIAODIR=/usr/local/ciao-4.3/bin
CIAO_INIT=source $(CIAODIR)/ciao.bash
BASEDIR=../..

chandra : *.tsv
	mkdir chandra
	for i in `grep chandra $< | cut -f 4` ; do \
		if [ -d "$(BASEDIR)/chandra-obs/$$i" ] ; then \
			echo ">>> Linking archived ObsId $$i <<<" ; \
			ln -s ../$(BASEDIR)/chandra-obs/$$i chandra ; \
		else \
			echo ">>> Downloading ObsId $$i <<<" ; \
			$(CIAO_INIT) && download_chandra_obsid $$i ; \
			mv $$i "$(BASEDIR)/chandra-obs/" ; \
			ln -s ../$(BASEDIR)/chandra-obs/$$i chandra ; \
		fi ; \
	done

clean :
	rm -rf chandra

