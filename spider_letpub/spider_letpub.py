#!/usr/lib/python2
# -*- coding:utf-8 -*-
import requests
import codecs
import re
import sys
import time
pagea=1
pages=365

for p in range(pagea,pages+1):
	time.sleep(3)
	urls=r'http://www.letpub.com.cn/index.php?page=journalapp&view=search&searchname=&searchissn=&searchfield=&searchimpactlow=2&searchimpacthigh=&searchimpacttrend=&searchscitype=&searchcategory1=&searchcategory2=&searchjcrkind=&searchopenaccess=&searchsort=relevance&searchsortorder=desc&currentsearchpage='+str(p)+r'#journallisttable'
	headers={"User-Agent":"Mozilla/5.0 (Windows NT 10.0; WOW64; rv:45.0) Gecko/20100101 Firefox/45.0"}
	html=requests.get(urls,headers=headers)
#html.encoding="gbk"
	html=html.text
	tables=re.compile(r'<tr><td style="border.+?</tr>',re.S)
	alltables=tables.findall(html)
	f=codecs.open('sci_journal.txt','a','utf-8')
	for x in alltables:
		cols=re.compile(r'>([^><]+)<',re.S).findall(x)
		for col in cols:
			f.write(col+"\t")
		f.write("\n")
	print "find %s in page %s" % (str(len(alltables)),str(p))
	f.close()




