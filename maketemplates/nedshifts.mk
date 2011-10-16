include $(RAWBASEDIR)/maketemplates/master.mk

.PHONY: all clean

all : 

# Please don't run this unless it's all effed
clean :
	rm -f *.tsv

% : 
	$(PYTHON) $(BASEDIR)/bin/get_ned.py $(shell echo $@ | cut -d "R" -f 1 | sed -e 's/+/ +/' -e 's/-/ -/' -e 's/_/:/g') $(shell echo $@ | cut -d "R" -f 2 | sed -e 's/.tsv//') > $@
