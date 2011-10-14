include $(RAWBASEDIR)/maketemplates/master.mk
RADIUS=$(shell $(PYTHON) $(BASEDIR)/bin/get_master_radius.py)
NEDARCHIVE="$(BASEDIR)/Data/nedshifts"

.PHONY: all clean

all : 

# Don't run this unless it's all effed
clean :
	rm -f *.tsv

% : 
	echo $(subst "+", " +", $(subst "-"," -", $@))
