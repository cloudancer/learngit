#!/bin/bash
#initial centos7 for mysql server

env_check()
{
	if [[ $(id -u) != "0" ]]; then
	    printf "\e[42m\e[31mError: You must be root to run this install script.\e[0m\n"
	    exit 1
	fi

	if [[ $(grep "release 7." /etc/redhat-release 2>/dev/null | wc -l) -eq 0 ]]; then
	    printf "\e[42m\e[31mError: Your OS is NOT CentOS 7 or RHEL 7.\e[0m\n"
	    printf "\e[42m\e[31mThis install script is ONLY for CentOS 7 and RHEL 7.\e[0m\n"
	    exit 1
	fi
	clear
}

g_echo()
{
	echo -e "\033[1;32m $* \033[0m"
}


selinux_firewall()
{
	g_echo "Disable firewalld and SELINUX"
	sed -i '/SELINUX/s/enforcing/disabled/' /etc/selinux/config
	systemctl disable firewalld.service
}

update_yumrepo()
{
    mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repobak
    wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
    yum install -y yum-utils device-mapper-persistent-data
    yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    yum clean all ; yum makecache
}

init_mysql()
{
    wget https://github.com/innotop/innotop/archive/v1.11.4.tar.gz
    tar xf v1.11.4.tar.gz ; cd innotop-1.11.4;perl Makefile.PL;make install
    wget https://launchpad.net/mydumper/0.9/0.9.1/+download/mydumper-0.9.1.tar.gz;tar xf mydumper-0.9.1.tar.gz
    cd mydumper-0.9.1;cmake . ;make ; make install
    wget https://github.com/lz4/lz4/archive/v1.8.0.tar.gz ; tar xf v1.8.0.tar.gz
    cd lz4-1.8.0 && make ; make install
    yum -y install https://dev.mysql.com/get/mysql57-community-release-el7-11.noarch.rpm
}

init_mysql_tools()
{
	yum -y install sysstat procps-ng perl-DBD-MySQL perl-DBI perl-ExtUtils-CBuilder perl-ExtUtils-MakeMaker perl-Time-HiRes perl-TermReadKey perl-IO-Socket-SSL perl-CPAN glib2-devel  libffi-devel glib2 zlib-devel pcre-devel openssl-devel libaio libaio-devel ncurses-devel make dmidecode dstat figlet glances htop iftop  iotop lrzsz lsof lftp man nc nethogs nfs-utils ntpdate rsync screen sysstat telnet unzip vim wget git screen grubby iptraf perf qperf qpress cmake glib2-devel pcre-devel gcc gcc-c++ telnet mlocate redhat-lsb-core autoconf automake libtool pkgconfig vim-* ruby
	yum -y update nss
	yum remove docker docker-common docker-selinux docker-engine ; yum -y install docker-ce
	systemctl start docker.service
    systemctl enable docker.service
    curl -sSL https://get.daocloud.io/daotools/set_mirror.sh | sh -s http://e637f1d4.m.daocloud.io;systemctl restart docker.service

#  yum -y install https://dev.mysql.com/get/Downloads/MySQLGUITools/mysql-utilities-1.6.5-1.el7.noarch.rpm
#  yum -y install https://www.percona.com/downloads/XtraBackup/Percona-XtraBackup-2.4.9/binary/redhat/7/x86_64/percona-xtrabackup-24-2.4.9-1.el7.x86_64.rpm
#  yum -y install https://www.percona.com/downloads/percona-toolkit/3.0.5/binary/redhat/7/x86_64/percona-toolkit-3.0.5-1.el7.x86_64.rpm
#  yum -y install https://www.percona.com/downloads/pmm/1.5.3/binary/redhat/7/x86_64/pmm-client-1.5.3-1.x86_64.rpm
#  yum -y install http://mirrors.yun-idc.com/epel/7/x86_64/h/htop-2.0.2-1.el7.x86_64.rpm
}


modify_limit()
{
	g_echo "modify_limit"
	mv /etc/security/limits.conf /etc/security/limits.conf-`date +"%Y-%m-%d_%H-%M-%S"`
	echo  "* soft nofile 65000" >> /etc/security/limits.conf
	echo  "* hard nofile 65535" >> /etc/security/limits.conf
	echo  "*   -   nofile 65535 " >>/etc/security/limits.conf
	echo  "echo never > /sys/kernel/mm/transparent_hugepage/enabled" >> /etc/rc.local
	echo never > /sys/kernel/mm/transparent_hugepage/enabled
	grep "pam_limits.so" /etc/pam.d/login
	if  [ $? -ne 0 ];then
			echo  "session    required     pam_limits.so" >> /etc/pam.d/login
	fi
}


modify_sysctl()
{
g_echo "modify_sysctl"
mv /etc/sysctl.conf /etc/sysctl.conf.`date +"%Y-%m-%d_%H-%M-%S"`
echo -e "kernel.core_uses_pid = 1\n"\
"kernel.msgmnb = 65536\n"\
"vm.swappiness = 5\n"\
"vm.overcommit_memory = 1\n"\
"fs.aio-max-nr = 1048576\n"\
"vm.dirty_background_ratio = 5\n"\
"vm.dirty_ratio = 10\n"\
"fs.file-max = 65535\n"\
"kernel.msgmax = 65536\n"\
"kernel.shmmax = 68719476736\n"\
"kernel.shmall = 4294967296\n"\
"net.core.netdev_max_backlog = 8192\n"\
"net.core.rmem_default = 8388608\n"\
"net.core.rmem_max = 16777216\n"\
"net.core.somaxconn = 32768\n"\
"net.core.wmem_default = 8388608\n"\
"net.core.wmem_max = 16777216\n"\
"net.ipv4.conf.default.rp_filter = 1\n"\
"net.ipv4.conf.default.accept_source_route = 0\n"\
"net.ipv4.ip_forward = 1\n"\
"net.ipv4.ip_local_port_range = 1024 65535\n"\
"net.ipv4.tcp_fin_timeout = 30\n"\
"net.ipv4.tcp_keepalive_time = 120\n"\
"net.ipv4.tcp_max_orphans = 3276800\n"\
"net.ipv4.tcp_max_syn_backlog = 8192\n"\
"net.ipv4.tcp_max_tw_buckets = 6000\n"\
"net.ipv4.tcp_mem = 94500000 915000000 927000000\n"\
"net.ipv4.tcp_rmem = 4096    87380   16777216\n"\
"net.ipv4.tcp_sack = 1\n"\
"net.ipv4.tcp_syn_retries = 1\n"\
"net.ipv4.tcp_synack_retries = 1\n"\
"net.ipv4.tcp_syncookies = 1\n"\
"net.ipv4.tcp_timestamps = 0\n"\
"net.ipv4.tcp_tw_recycle = 1\n"\
"net.ipv4.tcp_tw_reuse = 1\n"\
"net.ipv4.tcp_window_scaling = 1\n"\
"net.ipv4.tcp_wmem = 4096    16384   16777216\n" > /etc/sysctl.conf
sysctl -p
}

modify_profile()
{
	g_echo "config profile"
    sed -i 's/HISTSIZE=1000/HISTSIZE=2000/' /etc/profile
	sed -i '/HISTSIZE=2000/a\HISTTIMEFORMAT="%F %T "' /etc/profile
}

modify_vimrc()
{
g_echo "config vim"
cat > /root/.vimrc << 'EOF'
set nocompatible
set ruler
syntax on
syntax enable
set ts=4
set noerrorbells
set sw=4
filetype on
set linespace=0
set number
set showmatch
set incsearch
set hlsearch
set winminheight=0
EOF
}

modify_timezone()
{
	g_echo "modify_timezone"
	\cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
	echo "0 * * * * ntpdate ntp.shu.edu.cn > /dev/null && hwclock --systohc" >> /var/spool/cron/root
	systemctl restart crond.service
	systemctl disable ntpd.service
}

main()
{
	env_check;sleep 2s;g_echo;selinux_firewall;modify_timezone;update_yumrepo;modify_limit;modify_sysctl;modify_profile;modify_vimrc;init_mysql;init_mysql_tools;
}

echo -e "======*\e[1;36mInit\e[0m*======"
read -p "Initialize OS yes or no ? [no]: " RETVAL
RETVAL=${RETVAL:-n}
if [ "$RETVAL" = y -o "$RETVAL" = Y -o "$RETVAL" = yes -o "$RETVAL" = YES ]; then
main
fi
