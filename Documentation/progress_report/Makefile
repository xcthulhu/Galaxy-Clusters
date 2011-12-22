all: progress_report-latex.pdf

%-latex.pdf : %-latex.tex
	pdflatex $< 
	bibtex $(patsubst %.tex, %.aux, $<)
	pdflatex $<
	pdflatex $< 
	pdflatex $< 

%.pdf : %.tm
	texmacs -c $< $@ -q

clean : 
	rm -f *.pdf *.ps *.log *.aux *.out
