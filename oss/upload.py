#!/usr/bin/python

import oss2
import os
import sys
import re
import gzip

pattern = re.compile(r'.*')
alias = os.getenv('OSS_ALIAS', "static")

if len(sys.argv) > 1 :
	alias = sys.argv[1]

if len(sys.argv) > 2 :
	pattern = re.compile(sys.argv[2])

access_key_id = os.getenv('OSS_ACCESS_KEY_ID', '')
access_key_secret = os.getenv('OSS_ACCESS_KEY_SECRET', '')
bucket_name = os.getenv('OSS_BUCKET', '')
endpoint = os.getenv('OSS_ENDPOINT', '')

bucket = oss2.Bucket(oss2.Auth(access_key_id, access_key_secret), endpoint, bucket_name)

def fail(message):
	print "[FAIL] " + message
	exit(3)

if not bucket:
	fail("oss2.Bucket")

for parent,dirnames,filenames in os.walk("."):
	for fname in filenames:
		if not fname.startswith("."):
			name = ""
			if parent == "." :
				name = alias + "/" + fname
			else:
				name = alias + parent[1:] + "/" + fname
			if pattern.search(name):
				print "[UP] [" +name+ "] " + parent + "/" + fname
				if name.endswith(".js"):
					f_in = open(parent + "/" + fname, 'rb')
					f_out = gzip.open(parent + "/" + fname + ".gz", 'wb')
					f_out.writelines(f_in)
					f_out.close()
					f_in.close()
					bucket.put_object_from_file(name, parent + "/" + fname + ".gz",headers = {'Content-Type':'text/javascript; charset=utf-8','Content-Encoding':'gzip'})
					os.remove(parent + "/" + fname + ".gz")
				elif name.endswith(".css"):
					f_in = open(parent + "/" + fname, 'rb')
					f_out = gzip.open(parent + "/" + fname + ".gz", 'wb')
					f_out.writelines(f_in)
					f_out.close()
					f_in.close()
					bucket.put_object_from_file(name, parent + "/" + fname + ".gz",headers = {'Content-Type':'text/css; charset=utf-8','Content-Encoding':'gzip'})
					os.remove(parent + "/" + fname + ".gz")
				else:
					bucket.put_object_from_file(name, parent + "/" + fname)
				print "[OK] [" +name+ "] " + parent + "/" + fname 

