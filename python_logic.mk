ifeq ("$(shell [ -e /etc/redhat-release ] && echo -n okay)","okay")
  PYTHON=python2.6
else
  PYTHON=python
endif
