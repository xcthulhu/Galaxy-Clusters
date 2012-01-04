RAWBASEDIR=..
# Declares, $(PYTHON) and $(BIN)
include $(RAWBASEDIR)/maketemplates/master.mk

# Master map doesn't need to be built; it's only helpful for the presentation ~ Matt & Adi (Oct 21)
OBJS=master-clusters master-clusters/Makefile #master-map.pdf

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

%-clusters : %.tsv $(BIN)/make_catalogue.py
	# Cluster the observations
	$(PYTHON) $(BIN)/make_catalogue.py $< $@

%-clusters/Makefile : %-clusters 
	# Create Makefile for processing clusters
	echo RAWBASEDIR=$(RAWBASEDIR)/.. > $@
	echo include '$$(RAWBASEDIR)'/maketemplates/cluster_process.mk >> $@

##### Pictures #####
# Make a map of the galactic plane of the clusters the algorithm generated
ESO_-_Milky_Way.jpg : 
	wget http://upload.wikimedia.org/wikipedia/commons/6/60/ESO_-_Milky_Way.jpg -O $@

%-clusters/galaxy-clusters-according-to-ned.txt: %-clusters/Makefile
	make -C $(dir $@) $(notdir $@)

%-ned.tsv: %-clusters/galaxy-clusters-according-to-ned.txt
	ln -s $< $@

%-ned-map-UNCROPPED.pdf : $(BIN)/plot_ned_clusters.py %-ned.tsv ESO_-_Milky_Way.jpg 
	$(PYTHON) $^ $(CLSTR_SZ) $@

%-map-UNCROPPED.pdf : $(BIN)/plot_clusters.py %.tsv ESO_-_Milky_Way.jpg 
	$(PYTHON) $^ $(CLSTR_SZ) $@

%-map.pdf : %-map-UNCROPPED.pdf
	pdfcrop $< $@

clean:
	rm -rf $(OBJS) master.tsv *.jpg *.pdf
