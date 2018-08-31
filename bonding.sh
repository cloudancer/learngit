#!/bin/bash
##bond for centos6.5

cd /etc/sysconfig/network-scripts/ && touch ifcfg-bond0
NET_PATH=/etc/sysconfig/network-scripts
cat > $NET_PATH/ifcfg-bond0 <<EOF
DEVICE=bond0
TYPE=Ethernet
ONBOOT=yes
BOOTPROTO=static
BONDING_OPTS="miimon=80 mode=1"
EOF

read -p "IP: " ipmodi
echo "IPADDR=$ipmodi" >> $NET_PATH/ifcfg-bond0
read -p "MASK: " mask
echo "NETMASK=$mask" >> $NET_PATH/ifcfg-bond0
read -p "GATEWAY: " gateway
echo "GATEWAY=$gateway" >> $NET_PATH/ifcfg-bond0
read -p "HOSTNAME: " hostnam
sed -i '/HOSTNAME/cHOSTNAME='$hostnam'' /etc/sysconfig/network
cat $NET_PATH/ifcfg-bond0

echo "alias netdev-bond0 bonding" > /etc/modprobe.d/bonding.conf
echo "nameserver 172.16.65.10" >> /etc/resolv.conf

cp $NET_PATH/ifcfg-ens192 $NET_PATH/ifcfg-ens192.bk
cp $NET_PATH/ifcfg-ens224 $NET_PATH/ifcfg-ens224.bk

cat > $NET_PATH/ifcfg-ens192 <<EOF
DEVICE=ens192
TYPE=Ethernet
ONBOOT=yes
BOOTPROTO=static
MASTER=bond0
SLAVE=yes
EOF

cat > $NET_PATH/ifcfg-ens224 <<EOF
DEVICE=ens224
TYPE=Ethernet
ONBOOT=yes
BOOTPROTO=static
MASTER=bond0
SLAVE=yes
EOF

echo -e "\nifenslave ens192 ens224" >> /etc/rc.local

systemctl restart network
exit
