include $(RAWBASEDIR)/maketemplates/master.mk
.SECONDARY : 
.PHONY : all clean
.DELETE_ON_ERROR : 

WINDOWS=$(foreach X, $(ITER_VALS), \
            $(foreach Y, $(ITER_VALS), \
               $(X)_$(shell echo $(X) + $(CHANDRA_WINDOW_SIZE) | bc)_$(Y)_$(shell echo $(Y) + $(CHANDRA_WINDOW_SIZE) | bc) \
             ) \
         )
WINDOWSSRCS=$(foreach W, $(WINDOWS), $(W)/sources.txt)

all : sources.txt

makes : $(foreach W, $(WINDOWS), $(W)/Makefile)

distribute-sources : $(WINDOWS:=/sources.out)

%/sources.out : % %/Makefile
	make -C $< $(notdir $@)

%/Makefile : %
	echo RAWBASEDIR=$(RAWBASEDIR)/.. > $@
	echo EVT2=$(EVT2) >> $@
	echo XMIN=$(shell dirname $@ | cut -d'_' -f1) >> $@
	echo XMAX=$(shell dirname $@ | cut -d'_' -f2) >> $@
	echo YMIN=$(shell dirname $@ | cut -d'_' -f3) >> $@
	echo YMAX=$(shell dirname $@ | cut -d'_' -f4) >> $@
	echo include '$$(RAWBASEDIR)'/maketemplates/chandra_window.mk >> $@

%/sources.txt : % %/Makefile
	make -C $< $(notdir $@)

unclustered_sources.txt :  $(WINDOWSSRCS)
	cat $^ | sort | uniq > $@

sources.txt : unclustered_sources.txt
	$(PYTHON) $(BIN)/cluster_srcs.py $(SOURCE_CLSTR_ARCSECS) $< > $@

0% 1% 2% 3% 4% 5% 6% 7% 8% 9% :
	mkdir -p $@

clean : 
	rm -rf $(WINDOWS) *.txt
