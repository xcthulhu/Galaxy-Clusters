OBJS=chandra-clusters
GEN_TSVs=Chandra-nodups.tsv #XMM-Crossref-Chandra-nodups.tsv
SZ=5

all: $(GEN_TSVs) $(OBJS)

%-valid.tsv : %-raw.tsv valid_lines.py
	./valid_lines.py  $< > $@ 

%-nodups.tsv : %-valid.tsv
	uniq $< > $@

master.tsv : $(GEN_TSVs)
	cat $(GEN_TSVs) > $@

%-clusters : %.tsv
	./make_catalogue.py $(SZ) $< $@/map-UNCROPPED.pdf
	pdfcrop $@/map-UNCROPPED.pdf $@/map.pdf
	rm $@/map-UNCROPPED.pdf
	cd $@ && find . -iname "*.tsv" -exec wc -l '{}' \; | sort -nr > hits.txt

clean:
	rm -rf *.o *.hi *.pyc *.pdf $(OBJS) $(GEN_TSVs)
