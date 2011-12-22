all: progress_report.pdf

%.pdf : %.tm
	texmacs -c $< $@ -q

clean : 
	rm -f *.pdf *.ps
