#!/usr/bin/python

import os
import sys
import re


def fail(message):
	print "[FAIL] " + message
	exit(3)

def help():
	print "view.py -home . -o a.html -i a.html.view"
	exit(3)

v_home="."
v_out=""
v_in=""
v_debug=os.getenv('DEBUG', '')

print "V_DEBUG: " + v_debug

for i in range(1,len(sys.argv)):
	v = sys.argv[i]
	if v == "-home":
		v_home = sys.argv[i + 1]
		i +=1
	elif v == "-o":
		v_out = sys.argv[i + 1]
		i +=1
	elif v == "-i":
		v_in = sys.argv[i + 1]
		i +=1

if v_in == "" or v_out == "":
	help()

pattern_include = re.compile(r'<!--[ \t]?#include\((.*)\)[ \t]?-->')

def parse(v_home,v_fd,v_in):

	cd = os.path.dirname(v_in)

	fd = open(v_in,"r")

	if not fd:
		fail("Not Found " + v_in)

	text = fd.read()

	fd.close()

	match=pattern_include.search(text)

	while match:

		bi,ei = match.span()

		v_fd.write(text[0:bi])

		p = match.group(1)

		if p.startswith("~"):
			v_in = v_home + p[1:]
		else:
			v_in = os.path.join(cd,p)

		if v_debug!="" and os.stat(v_in + "-debug"):
			v_in = v_in + "-debug"

		parse(v_home,v_fd,v_in)

		text = text[ei:]

		match=pattern_include.search(text)

	v_fd.write(text)

v_fd = open(v_out,"w")

if v_fd:
	parse(v_home,v_fd,v_in)
	v_fd.close()

