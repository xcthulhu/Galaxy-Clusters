PYTHON=python

ifeq ("$(shell [ -e /opt/local/bin/python2.7 ] && echo -n okay)","okay")
  PYTHON=/opt/local/bin/python2.7
endif

ifeq ("$(shell [ -e /etc/redhat-release ] && echo -n okay)","okay")
  PYTHON=python2.6
endif
