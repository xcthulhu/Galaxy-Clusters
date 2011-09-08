BASEDIR=.
include $(BASEDIR)/python_logic.mk

OBJS=master-clusters
SZ=5

all: $(OBJS)

master.tsv : catalogues/master.tsv
	ln -s $< $@

catalogues/master.tsv :
	make -C catalogues master.tsv

%-clusters : %.tsv
	$(PYTHON) make_catalogue.py $(SZ) $< $@/map-UNCROPPED.pdf
	pdfcrop $@/map-UNCROPPED.pdf $@/map.pdf
	rm $@/map-UNCROPPED.pdf
	cd $@ && find . -iname "*.tsv" -exec wc -l '{}' \; | sort -nr > hits.txt
	./make_makefiles.sh $@
	cd $@ && ../chronicle_galaxy_clusters.sh .

clean:
	rm -rf *.o *.hi *.pyc $(OBJS) master.tsv
