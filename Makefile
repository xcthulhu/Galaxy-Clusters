OBJS=master-clusters
SZ=5

all: $(OBJS)

%-valid.tsv : %-raw.tsv valid_lines.py
	./valid_lines.py  $< > $@ 

%-nodups.tsv : %-valid.tsv
	uniq $< > $@

master.tsv : catalogues/master.tsv
	ln -s $< $@

catalogues/master.tsv :
	make -C catalogues master.tsv

%-clusters : %.tsv
	./make_catalogue.py $(SZ) $< $@/map-UNCROPPED.pdf
	pdfcrop $@/map-UNCROPPED.pdf $@/map.pdf
	rm $@/map-UNCROPPED.pdf
	cd $@ && find . -iname "*.tsv" -exec wc -l '{}' \; | sort -nr > hits.txt
	./make_makefiles.sh $@

clean:
	rm -rf *.o *.hi *.pyc $(OBJS) master.tsv
