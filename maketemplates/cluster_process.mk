# Make hates colons - astronomers love them :(
OBJS := $(shell echo $(patsubst %,%/Makefile,$(wildcard *:*:*:*:*)) | sed -e 's/:/\\:/g')

all : $(OBJS) #galaxy_clusters.txt 

hits.txt :
	find . -iname "*.tsv" -exec wc -l '{}' \; | sort -nr > $@

%/Makefile:
	echo RAWBASEDIR='$$(RAWBASEDIR)'/.. > $@
	echo include='$$(RAWBASEDIR)'/maketemplates/analyze.mk >> $@

galaxy_clusters-UNSORTED.txt :
	$(BASEDIR)/bin/chronicle_galaxy_clusters.sh . > $@

galaxy_clusters.txt : galaxy_clusters-UNSORTED.txt
	sort -nr $< > $@
