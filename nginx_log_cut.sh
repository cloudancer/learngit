#!/bin/bash  
#Rotate the Nginx logs to prevent a single logfile from consuming too much disk space.   
LOGS_PATH=/alidata/server/nginx/logs  
YESTERDAY=$(date -d "yesterday" +%Y-%m-%d)  
mv ${LOGS_PATH}/app_acc.log ${LOGS_PATH}/app_acc_${YESTERDAY}.log  
mv ${LOGS_PATH}/ssl.app.log ${LOGS_PATH}/ssl.app_${YESTERDAY}.log  
## 向 Nginx 主进程发送 USR1 信号。USR1 信号是重新打开日志文件  
kill -USR1 $(cat /var/run/nginx.pid)  

wait

cd ${LOGS_PATH}
tar -zcvf app_acc_${YESTERDAY}.log.tgz app_acc_${YESTERDAY}.log && rm -rf app_acc_${YESTERDAY}.log
mv app_acc_${YESTERDAY}.log.tgz /mnt/oss/nginxlog/
