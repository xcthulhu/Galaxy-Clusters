all : master.tsv

chandra.tsv : 
	./fetch_chandra_db.py | grep -v HTEG > $@

XMM.tsv : 
	./fetch_XMM_db.py | grep -v 'Slew Observation' > $@

ROSAT.tsv :
	./fetch_ROSAT_db.py > $@

master.tsv : chandra.tsv XMM.tsv ROSAT.tsv
	tail -n +2 chandra.tsv > $@
	tail -n +2 XMM.tsv >> $@
#	tail -n +2 ROSAT.tsv >> $@

clean : 
	rm -f *.tsv *.pyc
