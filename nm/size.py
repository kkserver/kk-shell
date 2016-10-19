#!/usr/bin/python

import os
import sys
import re

name=""
arch=""
size=""
stype=""
sname=""

pattern_name = re.compile(r'[^\(]*')
pattern_fname = re.compile(r'\(([^\(\)]*)\)')
pattern_arch = re.compile(r'\(for architecture ([a-zA-Z0-9]*)\)\:$')
pattern_detail = re.compile(r'([0-9]*) ([a-zA-Z]*) (.*)')
pattern_ltmp = re.compile(r'ltmp[0-9]*')
pattern_classname = re.compile(r'_OBJC_CLASS_\$_(.*)')

classs = {}

if len(sys.argv) > 0 :

	fd = open("./" + sys.argv[1] + ".csv","w")
	sfd = open("./" + sys.argv[1] + ".func.csv","w")

	fd.write("ARCH,FILE,SIZE\n")
	sfd.write("ARCH,FILE,TYPE,NAME,SIZE\n")

	nm = os.popen("nm -U -n -t d " + sys.argv[1])

	for ln in nm.readlines():
		match = pattern_name.search(ln)
		if match and match.group() == sys.argv[1]:
			if name != "":
				fd.write(arch + "," + name + "," + str(int(size)) + "\n")
			match = pattern_fname.search(ln)
			if match:
				name = match.group(1)
			size = ""
			stype = ""
			sname = ""
			match = pattern_arch.search(ln)
			if match:
				arch = match.group(1)
		else:
			match = pattern_detail.search(ln)
			if match:
				if size != "" and not pattern_ltmp.search(sname):
					sfd.write(arch + "," + name + "," + stype + "," + sname + ","+ str(int(match.group(1)) - int(size)) + "\n")
				size = match.group(1)
				stype = match.group(2)
				sname = match.group(3)
				if stype == "S":
					match = pattern_classname.search(sname)
					if match:
						classs[match.group(1)] = 0

	if name != "":
		fd.write(arch + "," + name + "," + str(int(size)) + "\n")	

	fd.close()
	sfd.close()

	fd = open("./" + sys.argv[1] + ".unused.csv","w")

	fd.write("CLASS\n")

	nm = os.popen("nm -u -n -t d " + sys.argv[1])

	for ln in nm.readlines():
		match = pattern_classname.search(ln)
		if match:
			classs[match.group(1)] = classs.get(match.group(1),0) + 1

	for k,v in classs.items():
		if v == 0 :
			fd.write(k + "\n")

	fd.close()


