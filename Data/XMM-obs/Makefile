RAWBASEDIR=../..
include $(RAWBASEDIR)/maketemplates/master.mk 

.PHONY : all empty empty/Makefile

all : 

%/Makefile : %
	echo 'RAWBASEDIR=$(RAWBASEDIR)/..' > $@
	echo include '$$(RAWBASEDIR)'/maketemplates/XMM_individual.mk >> $@

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
	fi
