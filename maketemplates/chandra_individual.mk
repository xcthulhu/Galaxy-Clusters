include $(RAWBASEDIR)/maketemplates/master.mk

B_BAND=evt2_broad_300_8000_green_band.fits
S_BAND=evt2_soft_300_2500_red_band.fits
H_BAND=evt2_hard_2500_8000_blue_band.fits
S1_BAND=evt2_s1_300_900_magenta_band.fits
S2_BAND=evt2_s2_900_2500_cyan_band.fits
FULL_BAND=evt2_full_300_10000_white_band.fits

BANDFITS=$(B_BAND) $(S_BAND) $(H_BAND) $(S1_BAND) $(S2_BAND) $(FULL_BAND)
BANDSOURCEFITS=$(patsubst %_band.fits,%_band_srcs.fits,$(BANDFITS))

OBJS=evt2.fits $(BANDFITS) $(BANDSOURCEFITS)

.PHONY : all clean

all : $(OBJS)

# Rules for creating & linking the evt2 file
evt2.fits : primary/evt2.fits
	ln -sf $< $@
	[ -h $@ ] && touch $@

primary/evt2.fits : primary/Makefile
	$(MAKE) -C $(dir $@) $(notdir $@)
	[ -h $@ ] && touch $@

primary/Makefile : 
	echo RAWBASEDIR=$(RAWBASEDIR)/.. > $@
	echo include '$$(RAWBASEDIR)'/maketemplates/chandra_primary.mk >> $@

# Rules for extracting a human being readable file from an EVT2 file

#--------------------------------------------------------------------------------
#Columns for Table Block EVENTS
#--------------------------------------------------------------------------------
# 
#ColNo  Name                 Unit        Type            
#   1   time                 s           Real8     S/C TT corresponding to mid-exposure
#   2   ccd_id                           Int2      CCD reporting event
#   3   node_id                          Int2      CCD serial readout amplifier node
#   4   expno                            Int4      Exposure number of CCD frame containing event
#   5   chip(chipx,chipy)    pixel       Int2      Chip coords
#   6   tdet(tdetx,tdety)    pixel       Int2      ACIS tiled detector coordinates
#   7   det(detx,dety)       pixel       Real4     ACIS detector coordinates
#   8   sky(x,y)             pixel       Real4     sky coordinates
#   9   pha                  adu         Int4      total pulse height of event
#  10   pha_ro               adu         Int4      total read-out pulse height of event
#  11   energy               eV          Real4     nominal energy of event (eV)
#  12   pi                   chan        Int4      pulse invariant energy of event
#  13   fltgrade                         Int2      event grade, flight system
#  14   grade                            Int2      binned event grade
#  15   status[4]                        Bit(4)    event status bits

evt2.tsv : evt2.fits
	$(CIAO_INIT) && dmlist "$<[cols #1,#2,#3,#4,#5,#6,#7,#8,#9,#10,#11,#12,#13,#14,#15,EQPOS]" data rows=1: | head -8

# Rules for detecting sources from a given band
evt2_%_band.fits : evt2.fits
	$(CIAO_INIT) && dmcopy "$<[energy>$(shell echo $@ | cut -f3 -d"_"),energy<$(shell echo $@ | cut -f4 -d"_")][bin sky=2]" $@

%_band_srcs.fits : %_band.fits
	$(CIAO_INIT) && wavdetect infile=$< outfile=$@ scellfile=scell-$@ imagefile=imagefile-$@ defnbkgfile=nbgd-$@ regfile=$@.reg scales="1.0 1.414 2.0 2.828 4.0 5.657 8" clobber=yes

clean :
	rm -f $(OBJS)
