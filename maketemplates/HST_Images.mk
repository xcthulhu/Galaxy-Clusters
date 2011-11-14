include $(RAWBASEDIR)/maketemplates/master.mk

all : ../FITS summary.pdf

summary.pdf : $(patsubst ../FITS/%.fits, %.pdf, $(wildcard ../FITS/*.fits))
	gs -q -sPAPERSIZE=letter -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -sOutputFile=$@ $^

../FITS : 
	$(MAKE) -C .. FITS/Makefile
	$(MAKE) -C ../FITS all

%-UNFILTERED-UNCROPPED.pdf : ../FITS/%.fits
	$(PYTHON) $(BIN)/unfiltered_hst_fits_show.py $< $@

%-UNFILTERED.pdf : %-UNFILTERED-UNCROPPED.pdf
	pdfcrop $< $@

%-FILTERED-UNCROPPED.pdf : ../FITS/%.fits
	$(PYTHON) $(BIN)/filtered_hst_fits_show.py $< $@

%-FILTERED.pdf : %-FILTERED-UNCROPPED.pdf
	pdfcrop $< $@

%.tex : %-FILTERED.pdf %-UNFILTERED.pdf
	sed -e "s/FILE1/$(patsubst %.tex,%-UNFILTERED.pdf,$@)/" -e "s/FILE2/$(patsubst %.tex,%-FILTERED.pdf,$@)/" -e "s/NAME/$(shell echo $@ | sed -e "s/.tex//" -e "s/_/UNDERSCORE/g")/" $(RAWBASEDIR)/maketemplates/combo.tex | sed -e 's/UNDERSCORE/\\_/g' > $@

%-UNCROPPED.pdf : %.tex
	pdflatex --job=$(patsubst %.pdf,%,$@) $<

%.pdf : %-UNCROPPED.pdf
	pdfcrop $< $@

clean :
	rm -f *.pdf *.aux *.log *.tex
