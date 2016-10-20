#!/usr/bin/python

import os
import sys
import re

pattern_name = re.compile(r'(.*)\.png$')

if len(sys.argv) > 0 :

	p = os.popen("find . -name \"*.png\"")

	for fname in p.readlines():
		match = pattern_name.search(fname)
		if match and os.stat(match.group(1) + ".png").st_size > 1024 * 3:
			os.system("cwebp -q 75 "+match.group(1)+".png -o "+match.group(1)+".webp")
			os.system("rm -f "+match.group(1)+".png")

	p.close()


