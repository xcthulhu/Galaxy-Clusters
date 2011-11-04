all: writeup.pdf

%.pdf : %.tm
	texmacs -c $< $@ -q

clean : 
	rm -f *.pdf *.ps
