include $(RAWBASEDIR)/maketemplates/master.mk

all : 

odfingest : ../work/ccf.cif
	rm -f *.SAS
	env SAS_ODF=. SAS_CCF=$< BIN=$(BIN) $(BIN)/odfingest.sh

../work/ccf.cif :
	$(MAKE) -C $(dir $@) $(notdir $@)

untar :
	tar xfzv *.tar.gz
	tar xfv *.[tT][aA][rR]

clean :
	rm -f *.FIT *.TAR *.ASC MANIFEST.* *.SAS
