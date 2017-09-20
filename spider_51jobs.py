#!/usr/lib/python2
# -*- coding:utf-8 -*-
import requests
import codecs
import re
import sys
#url ="http://search.51job.com/list/040000,000000,0000,00,9,99,%25E7%2594%259F%25E7%2589%25A9%25E4%25BF%25A1%25E6%2581%25AF,2,1.html?lang=c&stype=&postchannel=0000&workyear=99&cotype=99&degreefrom=99&jobterm=99&companysize=99&providesalary=99&lonlat=0%2C0&radius=-1&ord_field=0&confirmdate=9&fromType=&dibiaoid=0&address=&line=&specialarea=00&from=&welfare="
urls="http://search.51job.com/jobsearch/search_result.php?fromJs=1&jobarea=040000&keyword=生物信息&keywordtype=2&lang=c&stype=2&postchannel=0000&fromType=1&confirmdate=9"
joblist=[]
def jobsdetail(joburl):
    url=joburl
    headers={"User-Agent":"Mozilla/5.0 (Windows NT 10.0; WOW64; rv:45.0) Gecko/20100101 Firefox/45.0"}
    html=requests.get(url,headers=headers)
    html.encoding='gbk'
    html=html.text
    #html=html.encode("utf-8")
    #f=open('a','w')
    #f.write(html)
    #f.close()
#    sys.exit()
    pattern=re.compile(u'[\u4e00-\u9fa5]+<br>')
    detail=pattern.findall(html)
    #print detail
    #sys.exit()
    f=codecs.open('zhaoping_detail','w','utf-8')
    for i in range(len(detail)):
        
        #print detail[i].encode('utf-8')
        f.write(detail[i]+"\n")
    f.close
    sys.exit()
def getjobs(urls):
    global joblist
    url=urls
    headers={"User-Agent":"Mozilla/5.0 (Windows NT 10.0; WOW64; rv:45.0) Gecko/20100101 Firefox/45.0"}
#html = requests.get(url,headers=headers).text
#html.decode('utf-8')
    html=requests.get(url,headers=headers)
    html.encoding='gbk'
    html=html.text
#html=html.encode("gbk")
#print html
#patten=re.compile(r'<p class=\"t1 \">.+?a target=\"_blank\" title=\"(.+?)\"',re.S)
    jobs=re.compile(r'<p class=\"t1 \">.+?a target=\"_blank\" title=\"(.+?)\".+?href=\"(.+?)\".+?class=\"t2\"><a target=\"_blank\" title=\"(.+?)\".+?<span class=\"t4\">(.+?)<',re.S)
#patten=re.compile(r'<p class=\"t1 \">.+?a target=\"_blank\" title=\"(.+?)\".+?class=\"t2\"><a target=\"_blank\" title=\"(.+?)\"',re.M)
    position=jobs.findall(html)
#print position
    for i in range(len(position)):
        for j in range(len(position[i])):
            a=position[i][j].encode('utf-8')
    joblist=joblist+position
#print position
    nextpage=re.compile(r'li class="bk"><a href=\"(http.+?)\".+?>(.+?)</a></li>',re.S)
    newurls=nextpage.findall(html)  #(0)返回匹配r''的所有信息，(1)返回捕获的信息
    for url_tuple in newurls:
        if not url_tuple[1]==u'\u4e0b\u4e00\u9875':##保留“下一页”的编码
            continue
        else:
            return url_tuple[0]
    
    #f=codecs.open('zhaoping','w','utf-8')
    #f.write(html)
    #f.close()
    #return newurl
while urls:
    urls=getjobs(urls)

    
f=codecs.open('zhaoping','w','utf-8')
for i in range(len(joblist)):
    print joblist[i][1]
    #sys.exit()
    jobsdetail(joblist[i][1])
    f.write(str(i)+"\t"+"\t".join(joblist[i])+"\n")
    f.close
