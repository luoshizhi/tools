#!/usr/bin/python
import sys
import os
import glob
import re

def help():
	if len(sys.argv)<3:
		print "Usage:\npython %s bms.txt [rawdata dir*]" % sys.argv[0]
		sys.exit(127)

def readdir(*dir):
	patten=re.compile(r'_(1|2).fq.gz$')
	fqdir=[]
	lane_dir={}
	for onedir in dir:
		onedir=os.path.realpath(onedir)
		fqdir.extend( [ patten.sub('',i.strip()) for i in  os.popen("find %s -name \"*fq.gz\" ").readlines()])
	fqdir=set(fqdir)
	for onedir in fqdir:
		lane_dir[onedir.split("_")[-1]]=onedir
	return lane_dir





def main():
	help()
	lane_dir=readdir(sys.argv[2:])
	f=open(sys.argv[1])
	out=open("./_sample.info","w")
	for line in f:
		bmslists=line.strip().split("\t")
		[sample,lane]=bmslist[0:2]
		length=bmslist[-1].split(",")[0]
		if lane_dir.has_keys(lane):
			out.write("%s\t%s\t%s\n" %(sample,lane_dir[lane],length))
	f.close()
	out.close()




if __name__ == '__main__':
	main()

