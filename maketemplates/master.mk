BASEDIR=$(realpath $(RAWBASEDIR))

include $(BASEDIR)/maketemplates/python_logic.mk
BIN=$(BASEDIR)/bin

CIAODIR=/usr/local/ciao-4.3/bin
CIAO_INIT=source $(CIAODIR)/ciao.bash -o

SRC_CLSTR_RADIUS=3

XMMDIR=/usr/local/XMM/xmmsas_20110223_1803/
XMM_INIT=source $(XMMDIR)/
