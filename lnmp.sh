#!/bin/bash
#lnmp install,centos7 environment

#install new version openssl
yum install -y zlib zlib-devel gcc gcc-c++ pcre pcre-devel git
wget https://www.openssl.org/source/openssl-1.0.2o.tar.gz
tar zxvf openssl-1.0.2o.tar.gz
cd openssl-1.0.2o
./config --prefix=/usr --openssldir=/usr/local/openssl shared zlib
make && make install && cd $HOME
openssl version -a

#php7.1 install
yum install -y epel-release
rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm
if [ $? -eq 0 ];then
	yum install -y php71w php71w-bcmath php71w-common php71w-cli php71w-mysql php71w-pdo php71w-gd php71w-fpm php71w-intl php71w-mbstring php71w-mcrypt php71w-process php71w-pear php71w-xml php71w-xmlrpc php71w-pecl-redis php71w-opcache php71w-devel php71w-soap
fi
wait
if [ $? -eq 0 ];then
        sed -i 's/post_max_size = 8M/post_max_size = 16M/g' /etc/php.ini
        sed -i 's/max_input_time = 60/max_input_time = 300/g' /etc/php.ini
        sed -i 's/max_execution_time = 30/max_execution_time = 300/g' /etc/php.ini
        sed -i 's@^;date.timezone.*@date.timezone = Asia/Shanghai@' /etc/php.ini
        sed -i 's@^output_buffering =@output_buffering = On\noutput_buffering =@' /etc/php.ini
        sed -i 's@^;cgi.fix_pathinfo.*@cgi.fix_pathinfo=1@' /etc/php.ini
        sed -i 's@^expose_php = On@expose_php = Off@' /etc/php.ini
        sed -i 's@^request_order.*@request_order = "CGP"@' /etc/php.ini
        sed -i 's@^upload_max_filesize.*@upload_max_filesize = 16M@' /etc/php.ini
        sed -i 's@^;realpath_cache_size.*@realpath_cache_size = 2M@' /etc/php.ini
fi

systemctl enable php-fpm
systemctl start php-fpm
systemctl status php-fpm

#install nginx 1.14
rpm -Uvh http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm
yum install -y nginx
mkdir -p /server/www/
chown nginx.nginx /server/www/

#config php
touch /dev/shm/php-cgi.sock
chown nginx.nginx /dev/shm/php-cgi.sock
cd /var/lib/php
chown root.nginx session
chown root.nginx wsdlcache
cd $HOME
sed -i 's/user = apache/user = nginx/g' /etc/php-fpm.d/www.conf
sed -i 's/group = apache/group = nginx/g' /etc/php-fpm.d/www.conf
sed -i 's/listen = 127/;listen = 127/g' /etc/php-fpm.d/www.conf
sed -i '/127.0.0.1:9000/alisten = /dev/shm/php-cgi.sock' /etc/php-fpm.d/www.conf
sed -i 's/;listen.owner = nobody/listen.owner = nginx/g' /etc/php-fpm.d/www.conf
sed -i 's/;listen.group = nobody/listen.group = nginx/g' /etc/php-fpm.d/www.conf
sed -i 's/;listen.mode = 0660/listen.mode = 0660/g' /etc/php-fpm.d/www.conf
sed -i 's/pm.max_children = 50/pm.max_children = 100/g' /etc/php-fpm.d/www.conf
sed -i 's/pm.start_servers = 5/pm.start_servers = 25/g' /etc/php-fpm.d/www.conf
sed -i 's/pm.min_spare_servers = 5/pm.min_spare_servers = 10/g' /etc/php-fpm.d/www.conf
sed -i 's/pm.max_spare_servers = 35/pm.max_spare_servers = 70/g' /etc/php-fpm.d/www.conf
sed -i 's/;listen.backlog = 511/listen.backlog = 2048/g' /etc/php-fpm.d/www.conf
systemctl restart php-fpm

#config nginx
cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bk
cat > /etc/nginx/nginx.conf <<EOF
user  nginx;
worker_processes  auto;
worker_rlimit_nofile 51200;

error_log  /var/log/nginx/error.log warn;
pid        /var/run/nginx.pid;


events {
    use epoll;
    worker_connections 4096;
    multi_accept on;
}


http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    access_log  /var/log/nginx/access.log;

    server_tokens off;
    sendfile        on;
    tcp_nopush     on;
    tcp_nodelay    on;

    fastcgi_connect_timeout 300;
    fastcgi_send_timeout 300;
    fastcgi_read_timeout 120;
    fastcgi_buffer_size 64k;
    fastcgi_buffers 4 64k;
    fastcgi_busy_buffers_size 128k;
    fastcgi_temp_file_write_size 128k;
    fastcgi_intercept_errors on;

    keepalive_timeout  65;
    send_timeout 10;
    client_header_timeout 10;
    client_body_timeout 10;
    server_names_hash_bucket_size 128;
    client_header_buffer_size 32k;
    large_client_header_buffers 4 32k;
    client_max_body_size 1024m;
    client_body_buffer_size 10m;

    gzip on;
    gzip_buffers 16 8k;
    gzip_comp_level 5;
    gzip_http_version 1.1;
    gzip_min_length 1k;
    #gzip_proxied any;
    #gzip_vary on;
    gzip_types text/xml application/xml application/atom+xml application/rss+xml application/xhtml+xml image/svg+xml text/javascript application/javascri
pt application/x-javascript text/x-json application/json application/x-web-app-manifest+json text/css text/plain text/x-component font/opentype applicati
on/x-font-ttf application/vnd.ms-fontobject image/x-icon;
    gzip_disable "MSIE [1-6]\.(?!.*SV1)";

    open_file_cache max=100000 inactive=20s;
    open_file_cache_valid 30s;
    open_file_cache_min_uses 1;
    open_file_cache_errors on;

    log_format main '$http_x_forwarded_for - $remote_addr - $remote_user [$time_local] $host "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';

    include /etc/nginx/conf.d/*.conf;
}
EOF

systemctl enable nginx.service
systemctl start nginx.service
systemctl status nginx.service

#install mysql
rpm -Uvh http://repo.mysql.com//mysql57-community-release-el7-7.noarch.rpm
yum install -y mysql-community-server
systemctl enable mysqld
systemctl start mysqld
systemctl status mysqld
