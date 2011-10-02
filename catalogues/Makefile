BASEDIR=..
include $(BASEDIR)/python_logic.mk

all : master.tsv

chandra.tsv : 
	$(PYTHON) ./fetch_chandra_db.py | grep ACIS | grep -v "observed" > $@

XMM.tsv : 
	$(PYTHON) ./fetch_XMM_db.py | grep -v 'Slew Observation' | grep -v "dummy" > $@

ROSAT.tsv :
	$(PYTHON) ./fetch_ROSAT_db.py > $@

master.tsv : chandra.tsv XMM.tsv ROSAT.tsv
	tail -n +2 chandra.tsv > $@
	tail -n +2 XMM.tsv >> $@
#	tail -n +2 ROSAT.tsv >> $@

clean : 
	rm -f *.tsv *.pyc
