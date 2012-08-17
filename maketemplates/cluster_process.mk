include $(RAWBASEDIR)/maketemplates/master.mk
.PRECIOUS: %/Makefile
.DELETE_ON_ERROR : galaxy-clusters-according-to-ned.txt 
.PHONY : all analyze clean

all : galaxy-clusters-according-to-ned.txt

clean :
	rm -f *.txt

hits.txt :
	find . -iname "*.tsv" -exec wc -l '{}' \; | sort -nr > $@

makes : 
	find . -maxdepth 1 -name "*_*_*_*" -exec make '{}'/Makefile \;
	touch $@

nedshifts : 
	find . -maxdepth 1 -name "*_*_*_*" -exec make '{}'/nedshifts.tsv \;
	touch $@

%/XMM/Makefile: %/Makefile
	make -C $(dir $<) XMM/Makefile

%/chandra/Makefile: %/Makefile
	make -C $(dir $<) chandra/Makefile

%/Makefile:
	echo RAWBASEDIR=$(RAWBASEDIR)/.. > $@
	echo include '$$(RAWBASEDIR)'/maketemplates/analyze.mk >> $@

%/nedshifts.tsv : %/Makefile
	$(MAKE) -C $(dir $@) $(notdir $@)
	touch $@

galaxy-clusters-according-to-ned.txt : nedshifts
	$(BASEDIR)/bin/chronicle_galaxy_clusters_according_to_ned.sh $(LOWEST_Z) $(HIGHEST_Z) $(CLSTR_SZ) . | sort -nr > $@

galaxy-clusters.txt : nedshifts
	$(BASEDIR)/bin/chronicle_galaxy_clusters.sh . | sort -nr > $@

download : galaxy-clusters-according-to-ned.txt 
	find . -maxdepth 1 -name "*_*_*_*" -exec bash -c "grep '{}' $< > /dev/null && make -C '{}' download " \;

analyze : galaxy-clusters-according-to-ned.txt $(MAKES) $(CHANDRA_MAKES) $(XMM_MAKES)
	@for i in `cut -f2 $<` ; do \
		echo make -C `dirname $$i`/XMM ; \
		make -C `dirname $$i`/XMM ; \
	done
