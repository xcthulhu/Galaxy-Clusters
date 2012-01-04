all: progress_report-latex.pdf

../../Data/master-map.pdf:
	$(MAKE) -C $(dir $@) $(notdir $@)

../../Data/master-ned-map.pdf:
	$(MAKE) -C $(dir $@) $(notdir $@)

master-map.pdf: ../../Data/master-map.pdf
	ln -s $< $@

master-ned-map.pdf: ../../Data/master-ned-map.pdf
	ln -s $< $@

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
