#!/bin/bash

#initial centos7 which is mimimal install and develop tools

## shutdown firewall
function close_firewall(){
    setenforce 0
    systemctl disable firewalld && systemctl stop firewalld
    sed -i '/SELINUX/s/enforcing/disabled/' /etc/selinux/config
}
close_firewall

##set no one can change thses files
chattr +i /etc/passwd
chattr  +i /etc/shadow
chattr +i /etc/group
chattr +i /etc/gshadow
##set it out use this:chattr -i file

##convient set
echo "alias vi='vim'" >> /root/.bashrc
echo "export HISTTIMEFORMAT='%F %T '" >> /root/.bashrc

#set timezone
cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime 

##Set file handle
cat >> /etc/security/limits.conf<<-EOF
* soft nofile 65535
* hard nofile 65535
EOF

##kernel optimize
cat >> /etc/sysctl.conf <<EOF
fs.file-max = 999999
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_keepalive_time = 600
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_max_tw_buckets = 5000
net.ipv4.ip_local_port_range = 1024    61000
net.ipv4.tcp_rmem = 4096 32768 262142
net.ipv4.tcp_wmem = 4096 32768 262142
net.core.netdev_max_backlog = 8096
net.core.rmem_default = 262144
net.core.wmem_default = 262144
net.core.rmem_max = 2097152
net.core.wmem_max = 2097152
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_max_syn_backlog = 1024
EOF
sysctl -p

##yum source set aliyun
cd /etc/yum.repos.d/ && mv CentOS-Base.repo CentOS-Base.repo.backup
cat > /etc/yum.repos.d/CentOS-Base.repo <<EOF
# CentOS-Base.repo
#
 
[base]
name=CentOS-\$releasever - Base - mirrors.aliyun.com
failovermethod=priority
baseurl=http://mirrors.aliyun.com/centos/\$releasever/os/\$basearch/
        http://mirrors.aliyuncs.com/centos/\$releasever/os/\$basearch/
        http://mirrors.cloud.aliyuncs.com/centos/\$releasever/os/\$basearch/
gpgcheck=1
gpgkey=http://mirrors.aliyun.com/centos/RPM-GPG-KEY-CentOS-7
 
#released updates 
[updates]
name=CentOS-\$releasever - Updates - mirrors.aliyun.com
failovermethod=priority
baseurl=http://mirrors.aliyun.com/centos/\$releasever/updates/\$basearch/
        http://mirrors.aliyuncs.com/centos/\$releasever/updates/\$basearch/
        http://mirrors.cloud.aliyuncs.com/centos/\$releasever/updates/\$basearch/
gpgcheck=1
gpgkey=http://mirrors.aliyun.com/centos/RPM-GPG-KEY-CentOS-7
 
#additional packages that may be useful
[extras]
name=CentOS-\$releasever - Extras - mirrors.aliyun.com
failovermethod=priority
baseurl=http://mirrors.aliyun.com/centos/\$releasever/extras/\$basearch/
        http://mirrors.aliyuncs.com/centos/\$releasever/extras/\$basearch/
        http://mirrors.cloud.aliyuncs.com/centos/\$releasever/extras/\$basearch/
gpgcheck=1
gpgkey=http://mirrors.aliyun.com/centos/RPM-GPG-KEY-CentOS-7
 
#additional packages that extend functionality of existing packages
[centosplus]
name=CentOS-\$releasever - Plus - mirrors.aliyun.com
failovermethod=priority
baseurl=http://mirrors.aliyun.com/centos/\$releasever/centosplus/\$basearch/
        http://mirrors.aliyuncs.com/centos/\$releasever/centosplus/\$basearch/
        http://mirrors.cloud.aliyuncs.com/centos/\$releasever/centosplus/\$basearch/
gpgcheck=1
enabled=0
gpgkey=http://mirrors.aliyun.com/centos/RPM-GPG-KEY-CentOS-7
 
#contrib - packages by Centos Users
[contrib]
name=CentOS-\$releasever - Contrib - mirrors.aliyun.com
failovermethod=priority
baseurl=http://mirrors.aliyun.com/centos/\$releasever/contrib/\$basearch/
        http://mirrors.aliyuncs.com/centos/\$releasever/contrib/\$basearch/
        http://mirrors.cloud.aliyuncs.com/centos/\$releasever/contrib/\$basearch/
gpgcheck=1
enabled=0
gpgkey=http://mirrors.aliyun.com/centos/RPM-GPG-KEY-CentOS-7
EOF

#install basic packages
if [ $? -eq 0 ];then
    yum update -y && yum upgrade -y
    yum install -y net-tools vim make gcc gcc-c++ ncurses-devel wget git
    yum clean all && reboot
fi
