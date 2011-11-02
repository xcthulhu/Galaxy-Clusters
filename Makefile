all:

install : ciao-install.sh ciao-4.3
	perl -e 'print "/tmp\n/usr/local/\ny\ny\nn\n"' | ./ciao-install.sh

ciao-4.3 :
	mkdir ciao-4.3

ciao-install.sh :
	wget http://cxc.harvard.edu/cgi-gen/ciao/ciao43_install.cgi -O $@
	chmod +x $@
