#!/bin/bash

account='dh78888'
password=`echo -n "8wGdGzx8"| openssl md5| cut -d ' ' -f 2`
msgid=''
phones=$1
content=$2
#sign="\u3080\u6c38\u5829\u5b9d\u3811"
sign="【告警】"
subcode=14021
sendtime=`date +'%Y%m%d%H%M'`

url='http://wt.3tong.net/json/sms/Submit'

data="{\"content\": \"$content\", \"account\": \"$account\", \"sendtime\": \"$sendtime\", \"phones\": \"$phones\", \"msgid\": \"$msgid\", \"password\": \"$password\", \"subcode\": \"$subcode\", \"sign\": \"$sign\"}"

#echo $data

curl -H "Content-Type:application/json" -d "$data" $url
