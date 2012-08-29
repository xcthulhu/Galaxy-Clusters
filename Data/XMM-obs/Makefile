RAWBASEDIR=../..
include $(RAWBASEDIR)/maketemplates/master.mk 

.PHONY : all empty empty/Makefile clean

all : 

makes : 
	find . -maxdepth 1 -type d -name "[0-9]*" -exec make '{}'/Makefile \;

all-% : 
	find . -maxdepth 1 -type d -name "[0-9]*" -exec make -C '{}' $(patsubst all-%,%,$@) \;

science-% : 
	find . -maxdepth 1 -type d -name "[0-9]*" -exec make -C '{}' science/$(patsubst science-%,%,$@) \;

%/Makefile : %
	if [ ! -f $</empty ] ; then \
		echo 'RAWBASEDIR=$(RAWBASEDIR)/..' > $@ ; \
		echo include '$$(RAWBASEDIR)'/maketemplates/XMM_individual.mk >> $@ ; \
	fi

% :
	$(eval OBSURL := $(shell $(PYTHON) $(BASEDIR)/bin/get_XMM_obs_url.py $@))
	@if [ $(OBSURL) ]  ; then \
		if [ $(shell echo $(OBSURL) | grep odf) ] ; then \
			echo ">>> OBSERVATION INCOMPLETE; ONLY ODF AVAILABLE <<<" ; \
			echo ">>> RETRIEVING $(OBSURL) to $(shell pwd)/$@/odf/$(notdir $(OBSURL)) <<<" ; \
			mkdir -p $@/odf ; \
			curl -v -u 'anonymous:anonymous@' $(OBSURL) > $@/odf/$(notdir $(OBSURL)) ; \
		else \
			echo ">>> RETRIEVING $(OBSURL) to $(shell pwd)/$@ <<<" ; \
			curl -v -u 'anonymous:anonymous@' $(OBSURL) | tar x ; \
		fi \
	else \
		echo ">>> COULD NOT GET URL FOR OBSID \"$@\" <<<" ; \
		echo "[SEE $(BASEDIR)/Data/XMM-obs/XSA-logs/$@.html for details]" ; \
		echo ">>> LINKING empty/ to $@ <<<" ; \
		echo ln -s empty $@ ; \
		ln -s empty $@ ; \
	fi
