include $(RAWBASEDIR)/maketemplates/master.mk
.SECONDARY : 
.PHONY : all fluxes
PBK=$(shell find ../../../work/ -name "*_pbk0.fits" | head -1 )

all : fluxes

fluxes : foreground_fluxp.txt background_fluxp.txt

foreground_fluxp.txt : $(MY_OCTAVES:=-foreground_fluxp.txt)
	ln -sf $< $@

background_fluxp.txt : $(MY_OCTAVES:=-background_fluxp.txt)
	ln -sf $< $@ 

../../$(EVT2) :
	make -C ../.. $(basename $@)

%foreground.fits : ../../$(EVT2)
	$(CIAO_INIT) && dmcopy "$<[events][energy=$(shell echo $@ | cut -d'-' -f1):$(shell echo $@ | cut -d'-' -f2)][(ra,dec)=circle($(RA),$(DEC),$(RADIUS)\")]" $@

%background.fits : ../../$(EVT2)
	$(CIAO_INIT) && dmcopy "$<[events][energy=$(shell echo $@ | cut -d'-' -f1):$(shell echo $@ | cut -d'-' -f2)][(ra,dec)=annulus($(RA),$(DEC),$(shell echo "scale=2; $(RADIUS) * 1.5" | bc)\",$(shell echo "scale=2; $(RADIUS) * 3" | bc)\")]" $@

%_mod.fits : %.fits
	@if [ -s $< ] && $(PYTHON) $(BIN)/is_event_list_not_empty.py $< ; then \
		if [ -f $(PBK) ] ; then \
	 		echo eff2evt $< $@ pbkfile=$(PBK) ; \
			$(CIAO_INIT) && eff2evt $< $@ pbkfile=$(PBK) ; \
		else \
			echo eff2evt $< $@ ; \
			$(CIAO_INIT) && eff2evt $< $@ ; \
		fi \
	else \
		echo ">>> Event list $< empty; writing empty file $@ <<<"  ; \
		echo touch $@ ; \
		touch $@ ; \
	fi

%_fluxp.fits : %_mod.fits
	@if [ -s $< ] && $(PYTHON) $(BIN)/is_event_list_not_empty.py $< ; then \
		echo 'dmtcalc $< $@ expression="pflux=1/(QE*EA*LIVETIME)"' ; \
		$(CIAO_INIT) && dmtcalc $< $@ expression="pflux=1/(QE*EA*LIVETIME)" ; \
	else \
		echo ">>> Event list $< empty; writing empty file $@ <<<"  ; \
		echo touch $@ ; \
		touch $@ ; \
	fi

%_fluxp.txt : %_fluxp.fits
	@if [ -s $< ] && $(PYTHON) $(BIN)/is_event_list_not_empty.py $< ; then \
		echo 'dmlist "$<[cols pflux]" data | tail -n +8 | cut -c7- > $@' ; \
		$(CIAO_INIT) && dmlist "$<[cols pflux]" data | tail -n +8 | cut -c7- > $@ ; \
	else \
		echo ">>> Event list $< empty; writing empty file $@ <<<"  ; \
		echo touch $@ ; \
		touch $@ ; \
	fi

clean : 
	rm -rf *.fits params *.txt
