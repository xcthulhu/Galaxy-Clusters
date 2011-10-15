.PHONY : all

all :

ESO_-_Milky_Way.jpg : 
	wget http://upload.wikimedia.org/wikipedia/commons/6/60/ESO_-_Milky_Way.jpg -O $@

Milky-Way-Galactic-Plane-UNCROPPED.pdf : ESO_-_Milky_Way.jpg galaxy-projection.py
	./galaxy-projection.py $< $@

Milky-Way-Galactic-Plane.pdf : Milky-Way-Galactic-Plane-UNCROPPED.pdf galaxy-projection.py
	pdfcrop $< $@

Ecliptic-coordinate-system.svg :
	wget http://upload.wikimedia.org/wikipedia/commons/b/b3/Ecliptic_coordinate_system_%28celestial%29.svg -O $@

Ecliptic-coordinate-system.pdf : Ecliptic-coordinate-system.svg
	inkscape --export-pdf=$@ $<

Equatorial-coordinate-system.svg :
	wget http://upload.wikimedia.org/wikipedia/commons/c/c2/Equatorial_coordinate_system_%28celestial%29.svg -O $@

Equatorial-coordinate-system.pdf : Equatorial-coordinate-system.svg
	inkscape --export-pdf=$@ $<

Northwestern-University-Seal.svg :
	wget http://upload.wikimedia.org/wikipedia/en/6/69/Northwestern_University_Seal.svg -O $@

Northwestern-University-Seal.pdf : Northwestern-University-Seal.svg
	inkscape --export-pdf=$@ $<

Tree-of-life.svg : 
	        wget http://upload.wikimedia.org/wikipedia/commons/1/11/Tree_of_life_SVG.svg -O $@

Tree-of-life.pdf : Tree-of-life.svg
	inkscape --export-pdf=$@ $<

clean :
	rm -f *.pdf *.svg *.jpg
