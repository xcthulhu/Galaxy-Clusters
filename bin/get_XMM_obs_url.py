#!/usr/bin/env python
import urllib,urllib2,sys,re,os

if __name__ == '__main__':
	response = urllib2.urlopen('http://xsa.esac.esa.int:8080/aio/jsp/product.jsp?obsno=%s' % (sys.argv[1]))
	html = response.read()
	m = re.search('(?<=<A href=")(ftp://.*?)(">)', html)
	try: print m.group(1)
	except:
		if not os.path.exists("XSA-logs"): os.makedirs("XSA-logs")
		f = open(os.path.join('XSA-logs',"%s.html" % (sys.argv[1])), 'w')
		print >>f, html
		f.close()
		sys.exit(1)
