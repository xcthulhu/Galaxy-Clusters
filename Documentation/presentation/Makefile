PDFS=presentation.pdf notes.pdf
TEXS=main.tex

.PHONY: all clean

all : $(PDFS)

%.pdf : %.tex $(TEXS)
	pdflatex $<
	pdflatex $<
	pdflatex $<

clean : 
	rm -f *.toc *.aux *.log *.snm *.out *.nav $(PDFS) 
