OBJS=nubber master.tsv clusters
GEN_TSVs=Chandra-nodups.tsv XMM-Crossref-Chandra-nodups.tsv
SZ=5

all: $(GEN_TSVs) $(OBJS)

%-valid.tsv : %-raw.tsv valid_lines.py
	./valid_lines.py  $< > $@ 

nubber : nubber.hs
	ghc --make $<

%-nodups.tsv : %-valid.tsv nubber
	./nubber 3 $< > $@

master.tsv : $(GEN_TSVs)
	cat $(GEN_TSVs) > $@

clusters : master.tsv
	./make_catalogue.py $(SZ) $< clusters/map-UNCROPPED.pdf
	pdfcrop clusters/map-UNCROPPED.pdf clusters/map.pdf
	rm clusters/map-UNCROPPED.pdf
	cd clusters && find . -iname "*.tsv" -exec wc -l '{}' \; | sort -nr > hits.txt

clean:
	rm -rf *.o *.hi *.pyc *.pdf $(OBJS) $(GEN_TSVs)
