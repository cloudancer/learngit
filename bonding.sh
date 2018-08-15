#!/bin/bash
cd /etc/sysconfig/network-scripts/ && touch ifcfg-bond0
FILE_PATH=/etc/sysconfig/network-scripts/ifcfg-bond0
cat > $FILE_PATH <<EOF
DEVICE=bond0
TYPE=Ethernet
ONBOOT=yes
BOOTPROTO=static
BONDING_OPTS="miimon=80 mode=1"
EOF

read -p "IP:" ipmodi
read -p "MASK:" mask
read -p "gateway:" getw 
read -p "hostname:" host
echo "IPADDR=$ipmodi" >> $FILE_PATH
echo "NETMASK=$mask" >> $FILE_PATH
echo "GATEWAY=$getw" >> $FILE_PATH
#sed -i 's/HOSTNAME=.*$/HOSTNAME='$HOST'/g' /etc/sysconfig/network
sed -i '/HOSTNAME/cHOSTNAME='$host'' /etc/sysconfig/network
cat $FILE_PATH 

echo "alias netdev-bond0 bonding" > /etc/modprobe.d/bonding.conf
echo "nameserver 172.16.65.10" >> /etc/resolv.conf

NET_PATH=/etc/sysconfig/network-scripts
cp $NET_PATH/ifcfg-em1 $NET_PATH/ifcfg-em1.bak
cp $NET_PATH/ifcfg-em2 $NET_PATH/ifcfg-em2.bak
cat > $NET_PATH/ifcfg-em1 <<EOF
DEVICE=em1
TYPE=Ethernet
ONBOOT=yes
BOOTPROTO=static
MASTER=bond0
SLAVE=yes
EOF

cat > $NET_PATH/ifcfg-em2 <<EOF
DEVICE=em2
TYPE=Ethernet
ONBOOT=yes
BOOTPROTO=static
MASTER=bond0
SLAVE=yes
EOF

echo -e "\nifenslave em1 em2" >> /etc/rc.local

/etc/init.d/network restart
