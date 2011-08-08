OBJS=nubber Chandra-nodups.tsv Chandra-XMM-combo-nodups.tsv

all: $(OBJS)

%-valid.tsv : %-raw.tsv valid_lines.py
	./valid_lines.py  $< > $@ 

nubber : nubber.hs
	ghc --make $<

%-nodups.tsv : %-valid.tsv nubber
	./nubber 3 $< > $@

clean:
	rm -f *.o *.hi *.pyc $(OBJS)
