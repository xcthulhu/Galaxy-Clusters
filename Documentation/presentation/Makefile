IMAGES=images/Tree-of-life.pdf images/Northwestern-University-Seal.pdf flare-detection/Vincenty.pdf images/Ecliptic-coordinate-system.pdf images/Equatorial-coordinate-system.pdf images/Milky-Way-Galactic-Plane.pdf
PDFS=presentation.pdf notes.pdf 
TEXS=main.tex overview/overview.tex flare-detection/flare-detection.tex flare-detection/Vincenty.tex

.PHONY: all clean
.PRECIOUS : $(IMAGES)

all : $(PDFS)

images/% : 
	$(MAKE) -C images $(notdir $@)

flare-detection/% : 
	$(MAKE) -C flare-detection $(notdir $@)

%.pdf : %.tex $(TEXS) $(IMAGES)
	pdflatex $<
	pdflatex $<
	pdflatex $<

clean : 
	rm -f *.toc *.aux *.log *.snm *.out *.nav $(PDFS) 
	$(MAKE) -C images clean
