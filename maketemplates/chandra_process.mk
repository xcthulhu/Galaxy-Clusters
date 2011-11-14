EVT2=$(shell echo *_evt2.fits | head -1)

# The names of the FITS files for the bands of energy that we care about.
# Designations defined in Kim et al., http://arxiv.org/pdf/astro-ph/0611840
B_BAND=$(patsubst %_evt2.fits,%_broad_300_8000_green_band.fits,$(EVT2))
S_BAND=$(patsubst %_evt2.fits,%_soft_300_2500_red_band.fits,$(EVT2)) 
H_BAND=$(patsubst %_evt2.fits,%_hard_2500_8000_blue_band.fits,$(EVT2))
S1_BAND=$(patsubst %_evt2.fits,%_s1_300_900_magenta_band.fits,$(EVT2))
S2_BAND=$(patsubst %_evt2.fits,%_s2_900_2500_cyan_band.fits,$(EVT2))
FULL_BAND=$(patsubst %_evt2.fits,%_full_300_10000_white_band.fits,$(EVT2))

BANDFITS=$(B_BAND) $(S_BAND) $(H_BAND) $(S1_BAND) $(S2_BAND) $(FULL_BAND)

B_SRCS=$(patsubst %.fits,%_srcs.fits,$(B_BAND)) 
S_SRCS=$(patsubst %.fits,%_srcs.fits,$(S_BAND)) 
H_SRCS=$(patsubst %.fits,%_srcs.fits,$(H_BAND)) 
S1_SRCS=$(patsubst %.fits,%_srcs.fits,$(S1_BAND)) 
S2_SRCS=$(patsubst %.fits,%_srcs.fits,$(S2_BAND)) 
FULL_SRCS=$(patsubst %.fits,%_srcs.fits,$(FULL_BAND)) 

BANDSRCS=$(B_SRCS) $(S_SRCS) $(H_SRCS) $(S1_SRCS) $(S2_SRCS) $(FULL_SRCS)

# The all rule specifies what shall be done with a bare "make" command or "make all"
all : evt2.fits #$(SOURCES) $(BANDFITS) $(BANDSRCS)

# Rules for making evt2.fits file
evt2.fits : primary/evt2.fits
	ln -s $< $@

primary/evt2.fits : primary/Makefile
	$(MAKE) -C $(patsubst $(OBSDIR)/%,%/Makefile,$@) $(dir $@) $(notdir $@)

primary/Makefile : 
	echo RAWBASEDIR=$(RAWBASEDIR)/.. > $@
	echo include '$$(RAWBASEDIR)'/maketemplates/chandra_primary.mk >> $@

# Rule for extracting a given band
%_band.fits : $(EVT2)
	$(CIAO_INIT) && dmcopy "$<[energy>$(shell echo $@ | cut -f3 -d"_"),energy<$(shell echo $@ | cut -f4 -d"_")][bin sky=2]" $@

# Rule for detecting sources from a given band
%_band_srcs.fits : %_band.fits
	rm -f /tmp/`echo $@ | sed -e 's/.fits//'`*
	$(CIAO_INIT) && wavdetect infile=$< outfile=$@ scellfile=scell-$@ imagefile=imagefile-$@ defnbkgfile=nbgd-$@ regfile=$@.reg scales="1.0 1.414 2.0 2.828 4.0 5.657 8" clobber=yes 

# Rule for extracting sky to celestial conversion rules
%.coords : %.fits
	$(CIAO_INIT) && dmlist "$<[cols ccd_id,EQPOS]" data rows=1: > $@

# Rule for creating master region list (in progress)
%_srcs.reg : $(BANDFITS)
	echo $^

clean : 
	rm -f *.reg scell-*.fits imagefile-*.fits nbgd-*.fits *.reg $(BANDFITS)

#%_broad_300_8000_green_band.fits %_soft_300_2500_red_band.fits 

#%_chips : %_evt2.fits
#	for i in `seq 0 15` ; do  \
#		$(CIAO_INIT) && ( ( [ `dmstat "$<[ccd_id=$$i]" | grep max | grep -v '(' | cut -f2 | uniq` = "0" ] && [ `dmstat "$<[ccd_id=$$i]" | grep min | grep -v '(' | cut -f2 | uniq` = "0" ] ) || echo $$i >> $@ ) ; \
#	done

#$(CIAO_INIT) && dmcopy "$<[energy>`echo $$banddef |cut -f2 -d"|"`,energy<`echo $$banddef|cut -f3 -d"|"`,ccd_id=$$i][bin sky=1]" `echo $$banddef|cut -f1 -d"|"`-CCD$$i-$< ; \
#cat CCD$$i-$@.reg >> $@ ; \
#$(CIAO_INIT) && wavdetect infile="`echo $$banddef|cut -f1 -d"|"`-CCD$$i-$<" outfile=CCD$$i-$@.fits scellfile=scell-CCD$i-$@.fits imagefile=imagefile-CCD$$i-$@.fits defnbkgfile=nbgd-CCD$$i-$@.fits regfile=CCD$$i-$@.reg scales="2.0 4.0" clobber=yes ; \
