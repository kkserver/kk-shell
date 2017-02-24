#!/usr/bin/python

import oss2
import os
import sys
import re

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
				oss2.resumable_upload(bucket, name, parent + "/" + fname)
				print "[OK] [" +name+ "] " + parent + "/" + fname 

