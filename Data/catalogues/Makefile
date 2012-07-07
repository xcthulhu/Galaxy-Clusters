RAWBASEDIR=../..
.DELETE_ON_ERROR : chandra.tsv XMM.tsv ROSAT.tsv master.tsv
include $(RAWBASEDIR)/maketemplates/master.mk

all : master.tsv

chandra.tsv : 
	$(PYTHON) $(BIN)/fetch_chandra_db.py | grep ACIS | grep -v "observed" > $@

XMM.tsv : 
	$(PYTHON) $(BIN)/fetch_XMM_db.py | grep -v 'Slew Observation' | grep -v "dummy" > $@

ROSAT.tsv :
	$(PYTHON) $(BIN)/fetch_ROSAT_db.py > $@

master.tsv : chandra.tsv XMM.tsv ROSAT.tsv
	tail -n +2 chandra.tsv > $@
	tail -n +2 XMM.tsv >> $@
#	tail -n +2 ROSAT.tsv >> $@

clean : 
	rm -f *.tsv *.pyc
