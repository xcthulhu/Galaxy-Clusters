#!/usr/bin/env python
import urllib,urllib2,sys,re

if __name__ == '__main__':
	response = urllib2.urlopen('http://xsa.esac.esa.int:8080/aio/jsp/product.jsp?obsno=%s' % (sys.argv[1]))
	html = response.read()
	m = re.search('(?<=<A href=")(ftp://.*?)(">)', html)
	print m.group(1)
