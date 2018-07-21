#!/user/bin/python3
#encoding:utf-8

import smtplib
from email.mime.text import MIMEText

email_host = 'smtp.mxhichina.com'
email_user = 'max@lawill.net'
email_pwd = 'Passw0rd'
maillist = '3578964@qq.com'

sender = email_user
msg = MIMEText('this is mail content')
msg['Subject'] = 'warning'
msg['From'] = sender
msg['To'] = maillist
smtp = smtplib.SMTP(email_host, 587)
smtp.login(email_user, email_pwd)
smtp.sendmail(sender, maillist, msg.as_string())
smtp.quit()
print('mail send success.')



class SendMail(object):
	def __init__(self, email_user, email_pwd, maillist, title, message, email_host='smtp.mxhichina.com', port=587):
		self.email_user = email_user
		self.email_pwd = email_pwd
		self.maillist = maillist
		self.title = title
		self.message = message
		self.email_host = email_host
		self.port = port
	def send_mail(self):
		msg = MIMEText(self.message)
		msg['Subject'] = self.title
		msg['From'] = self.email_user
		msg['To'] = self.maillist
		smtp = smtplib.SMTP(self.email_host, self.port)
		smtp.login(self.email_user, self.email_pwd)
		try:
			smtp.sendmail(self.email_user, self.maillist, msg.as_string())
		except Exception as e:
			print('mail send failed', e)
		else:
			print('mail succeed!')
		smtp.quit()


if __name__ == '__main__':
	m = SendMail(
		email_user='max@lawill.net', email_pwd='password', maillist='lawill@163.com',
		title='python mail', message='python mail you, ahahaha'
	)
	m.send_mail()



#!/usr/bin/python
#encoding:utf-8

import requests
import time
import json
import hashlib

def md5(str):
	encrypt = hashlib.md5()
	encrypt.update(str.encode(encoding='utf-8'))
	return encrypt.hexdigest()

url = 'http://wt.3tong.net/json/sms/Submit'

sendtime = time.strftime('%Y%m%d%H%M',time.localtime(time.time()))

data={
	"account":'dh78888',
	"password":md5('8wGdGzx8'),
	"msgid":'',
	"phones":'15028834928',
	"content":'zabbix warning',
	"sign":'【告警】',
	"subcode":'14021',
	"sendtime":sendtime
}

sendata = json.dumps(data)

action = requests.post(url,sendata)

print(action.text)

result = json.loads(action.text)
i = result['result']
if i == 0:
    print("message send successd")
else:
    print("message send failed")
