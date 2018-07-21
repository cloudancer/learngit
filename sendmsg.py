#!/usr/bin/python
#encoding:utf-8

import requests
import time
import json
import hashlib
import sys

def md5(str):
	hl = hashlib.md5()
	hl.update(str.encode(encoding='utf-8'))
	return hl.hexdigest()

def sendmsg(number, msg):
	url = 'http://wt.3tong.net/json/sms/Submit'	
	sendtime = time.strftime('%Y%m%d%H%M',time.localtime(time.time()))	

	data={
		"account":'dh78888',
		"password":md5('8wGdGzx8'),
		"msgid":'',
		"phones":number,
		"content":msg,
		"sign":'【告警】',
		"subcode":'14021',
		"sendtime":sendtime
	}	

	sendata = json.dumps(data)	
	action = requests.post(url,sendata)
	print(action.text)

number=sys.argv[1]
msg=sys.argv[2]
sendmsg(number, msg)
