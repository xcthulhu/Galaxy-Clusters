RAWBASEDIR=../../..
include $(RAWBASEDIR)/maketemplates/master.mk
.PHONY : all clean

all :

master-map.pdf: ../../../Data/master-map.pdf
	ln -fs $< $@

../../../Data/master-map.pdf: 
	make -C $(dir $@) $(notdir $@)

Sgr-A-star-orbits.png : 
	wget http://www.astro.ucla.edu/~ghezgroup/gc/images/2010orbits_img_hires.png -O $@

Sgr-A-star-orbits : Sgr-A-star-orbits.gif  
	mkdir $@
	convert $< $(patsubst %.gif,$@/%-\%d.png,$<)

Sgr-A-star-orbits.gif :
	wget http://www.astro.ucla.edu/~ghezgroup/gc/images/2011orbits_animfull.gif -O $@

Sgr-A-star-NOTROTATED.jpg :
	wget http://rsd-www.nrl.navy.mil/7213/lazio/GC/GC-P-BCD.nolabel-highres.jpg -O $@

Sgr-A-star.jpg : Sgr-A-star-NOTROTATED.jpg
	convert -rotate 90 $< $@

Blackbody.jpg : 
	wget http://imgs.xkcd.com/comics/science.jpg -O $@

ESO_-_Milky_Way.jpg : 
	wget http://upload.wikimedia.org/wikipedia/commons/6/60/ESO_-_Milky_Way.jpg -O $@

Zone-Of-Avoidance-UNCROPPED.pdf : ESO_-_Milky_Way.jpg zone-of-avoidance.py
	$(PYTHON) zone-of-avoidance.py $< $@

Milky-Way-Galactic-Plane-UNCROPPED.pdf : ESO_-_Milky_Way.jpg galaxy-projection.py
	$(PYTHON) galaxy-projection.py $< $@

Ecliptic-coordinate-system.svg :
	wget http://upload.wikimedia.org/wikipedia/commons/b/b3/Ecliptic_coordinate_system_%28celestial%29.svg -O $@

Ecliptic-coordinate-system.pdf : Ecliptic-coordinate-system.svg
	inkscape --export-pdf=$@ $<
	pdf2ps $@ $@.ps
	ps2pdf $@.ps $@

Equatorial-coordinate-system.svg :
	wget http://upload.wikimedia.org/wikipedia/commons/c/c2/Equatorial_coordinate_system_%28celestial%29.svg -O $@

Equatorial-coordinate-system.pdf : Equatorial-coordinate-system.svg
	inkscape --export-pdf=$@ $<
	pdf2ps $@ $@.ps
	ps2pdf $@.ps $@

Northwestern-University-Seal.svg :
	wget http://upload.wikimedia.org/wikipedia/en/6/69/Northwestern_University_Seal.svg -O $@

Northwestern-University-Seal.pdf : Northwestern-University-Seal.svg
	inkscape --export-pdf=$@ $<
	pdf2ps $@ $@.ps
	ps2pdf $@.ps $@

Tree-of-life.svg : 
	wget http://upload.wikimedia.org/wikipedia/commons/1/11/Tree_of_life_SVG.svg -O $@

Tree-of-life.pdf : Tree-of-life.svg
	inkscape --export-pdf=$@ $<
	pdf2ps $@ $@.ps
	ps2pdf $@.ps $@

clean :
	rm -f *.pdf *.svg *.jpg *.png *.gif
	rm -rf Sgr-A-star-orbits

# Probably conflicts with lots of other rules, so make it last
%.pdf : %-UNCROPPED.pdf
	pdfcrop $< $@
