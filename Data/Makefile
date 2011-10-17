RAWBASEDIR=..
# Declares, $(PYTHON) and $(BIN)
include $(RAWBASEDIR)/maketemplates/master.mk

OBJS=master-clusters master-clusters/Makefile master-map.pdf

SZ=5

.PRECIOUS: catalogues/master.tsv master.tsv

all: $(OBJS) 

##### Rules for Making Image Archive Directories #####
%-obs : 
	mkdir $@

%-obs/Makefile : %-obs
	echo 'RAWBASEDIR=$(RAWBASEDIR)/..' > $@
	echo 'include $$(RAWBASEDIR)/maketemplates/$<.mk' >> $@

##### Rules for Nedshift Archive Directory #####

nedshifts :
	mkdir $@

nedshifts/Makefile : nedshifts
	echo 'RAWBASEDIR=$(RAWBASEDIR)/..' > $@
	echo 'include $$(RAWBASEDIR)/maketemplates/$<.mk' >> $@

##### Rules for Generating the Master Catalogue #####

master.tsv : catalogues/master.tsv
	ln -s $< $@

catalogues/master.tsv :
	make -C catalogues master.tsv

%-clusters : %.tsv
	# Cluster the observations
	$(PYTHON) $(BIN)/make_catalogue.py $< $@

%-clusters/Makefile : %-clusters
	# Create Makefile for processing clusters
	echo RAWBASEDIR=$(RAWBASEDIR)/.. > $@
	echo include '$$(RAWBASEDIR)'/maketemplates/cluster_process.mk >> $@
	#./make_makefiles.sh $@
	#cd $@ && ../chronicle_galaxy_clusters.sh .
	#cd $@ && ../chronicle_galaxy_clusters_according_to_ned.sh .


##### Pictures #####
# Make a map of the galactic plane of the clusters the algorithm generated
%-map-UNCROPPED.pdf : %.tsv ESO_-_Milky_Way.jpg
	$(PYTHON) $(BIN)/plot_clusters.py $(SZ) $< $@

%-map.pdf : %-map-UNCROPPED.pdf
	pdfcrop $< $@

clean:
	rm -rf $(OBJS) master.tsv *.jpg *.pdf
