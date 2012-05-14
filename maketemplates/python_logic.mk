PYTHON=python

ifeq ("$(shell [ -e /opt/local/bin/python2.7 ] && echo -n okay)","okay")
  PYTHON=/opt/local/bin/python2.7
endif

ifeq ("$(shell sw_vers | grep 'ProductVersion:' | grep -o '[0-9]*\.[0-9]*\.[0-9]*' | cut -d'.' -f1,2)", "10.6")
  PYTHON=source $(BASEDIR)/venv/bin/activate && python
endif

ifeq ("$(shell [ -e /etc/redhat-release ] && echo -n okay)","okay")
  PYTHON=python2.6
endif
