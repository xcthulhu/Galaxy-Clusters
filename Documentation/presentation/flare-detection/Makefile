PDFS=Vincenty.pdf

.PHONY: all clean

all : $(PDFS)

%.pdf : %.tex 
	pdflatex $<
	pdflatex $<
	pdflatex $<

clean : 
	rm -f *.toc *.aux *.log *.snm *.out *.nav $(PDFS) 
