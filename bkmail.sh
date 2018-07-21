#!/bin/bash
# Date: 20180426
#this script do backup mysqldb and if do it fail sendEmail

maillist="343695@qq.com;nianjet@163.com"
#确保备份目录存在
[ -d /mnt/oss/bsb/$(date +"%Y-%m") ] || mkdir -p /mnt/oss/bsb/$(date +"%Y-%m")

BACKUP="/usr/bin/mysqldump -q --single-transaction -S /var/lib/mysql/mysql.sock -uroot -p81234ideal"

# 备份业务数据库
$BACKUP -B ultron | gzip > /mnt/oss/bsb/$(date +"%Y-%m")/bsb_$(date +"%F-%H-%M").sql.gz

if [ $? -eq 0 ]
then
        echo "`date +%Y/%m/%d-%H:%M:%S` ultron backup successd" >> /root/backup_log/ultron_db_backup.log
else
        echo "`date +%Y/%m/%d-%H:%M:%S` ultron backup failed, check the mail " >> /root/backup_log/ultron_db_backup.log
        /usr/local/bin/sendEmail -f max@lawill.net -t "$maillist" -s smtp.mxhichina.com:587 -u "backup failed" -o message-content-type=html -o message-charset=utf-8 -xu max@lawill.net -xp Passw0rd -m "ultron_db backup failed!"
fi

