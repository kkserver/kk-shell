#!/usr/bin/python

import os
import sys
import re



if len(sys.argv) > 0 :
	
	images = {}

	fd = open("./unused.csv","w")

	fd.write("FILE\n")

	pattern_name = re.compile(r'([^/@]*)(@[0-9]?x)?\.png$')

	p = os.popen("find . -name \"*.png\"")

	for fname in p.readlines():
		match = pattern_name.search(fname)
		if match:
			if not images.has_key(match.group(1)):
				images[match.group(1)] = 1
				pp = os.popen("grep -R --include=\"*.m\" '@\"" +match.group(1)+ "\"' " + sys.argv[1])
				rd = pp.readline()
				if not rd:
					fd.write(fname)
				else:
					print rd
				pp.close()

	p.close()

	pattern_name = re.compile(r'([^/@]*)(@[0-9]?x)?\.webp$')

	p = os.popen("find . -name \"*.webp\"")

	for fname in p.readlines():
		match = pattern_name.search(fname)
		if match:
			if not images.has_key(match.group(1)):
				images[match.group(1)] = 1
				pp = os.popen("grep -R --include=\"*.m\" '@\"" +match.group(1)+ "\"' " + sys.argv[1])
				rd = pp.readline()
				if not rd:
					fd.write(fname)
				else:
					print rd
				pp.close()

	p.close()

	fd.close()

