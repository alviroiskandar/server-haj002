#!/bin/bash

EM="ip netns exec master";
IPV4_PUB="45.83.104.102";

ip netns add master;
ip link add eth1 type veth peer eth1p;
ip link set eth1p netns master;
ip -n master link set lo up;
ip -n master link set eth1p up;
ip -n master addr add 10.3.3.1/24 dev eth1p;
ip -n master addr add fe80::1/64 dev eth1p;
ip link set eth1 up;

ip link set eth0 netns master;
ip -n master link set eth0 up;
ip -n master addr add 45.83.104.102/22 dev eth0;
ip addr add 10.3.3.2/24 dev eth1;
for i in \
  2a03:4000:46:179::5001 \
  2a03:4000:46:179::5002 \
  2a03:4000:46:179::5003 \
  2a03:4000:46:179::5004 \
  2a03:4000:46:179::5005; do
    ip -6 addr add $i/64 dev eth1;
    ip -n master -6 neigh add proxy $i dev eth0;
done;
ip -n master route add default via 45.83.104.1 dev eth0 proto static;
ip -n master -6 route add default via fe80::1 dev eth0 proto static metric 1024 onlink pref medium;
ip -n master -6 route add 2a03:4000:46:179::/64 dev eth1p;
ip route add default via 10.3.3.1 dev eth1;
ip -6 route add default via fe80::1 dev eth1 onlink;

sysctl -w net.ipv4.ip_forward=1;
sysctl -w net.ipv6.conf.all.forwarding=1;
$EM sysctl -w net.ipv6.conf.all.forwarding=1;
$EM sysctl -w net.ipv6.conf.all.accept_ra=2;
$EM sysctl -w net.ipv6.conf.all.accept_redirects=1;
$EM sysctl -w net.ipv6.conf.all.accept_ra_from_local=1;
$EM sysctl -w net.ipv6.conf.eth0.proxy_ndp=1;
$EM sysctl -w net.ipv6.conf.eth1p.proxy_ndp=1;
$EM sysctl -w net.ipv4.ip_forward=1;

$EM iptables -t nat -I PREROUTING -d $IPV4_PUB -j DNAT --to-destination 10.3.3.2;
$EM iptables -t nat -I OUTPUT -d $IPV4_PUB -j DNAT --to-destination 10.3.3.2;
$EM iptables -t nat -I POSTROUTING -s 10.3.3.0/24 ! -d 10.3.3.0/24 -j SNAT --to-source $IPV4_PUB;

# ipv4
iptables -t filter -P INPUT ACCEPT;
iptables -t filter -P FORWARD ACCEPT;
iptables -t filter -P OUTPUT ACCEPT;
iptables -t filter -F;
iptables -t filter -X;
iptables -t filter -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT;
iptables -t filter -A INPUT -p tcp -m multiport --dports 80,443,48588 -j ACCEPT;
iptables -t filter -A INPUT -p icmp -j ACCEPT;
iptables -t filter -A INPUT -s 10.3.3.0/24 -j ACCEPT;
iptables -t filter -A INPUT -i lo -j ACCEPT;
iptables -t filter -P INPUT DROP;

iptables -t filter -P FORWARD DROP;
iptables -t filter -P OUTPUT ACCEPT;

# ipv6
ip6tables -t filter -P INPUT ACCEPT;
ip6tables -t filter -P FORWARD ACCEPT;
ip6tables -t filter -P OUTPUT ACCEPT;
ip6tables -t filter -F;
ip6tables -t filter -X;
ip6tables -t filter -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT;
ip6tables -t filter -A INPUT -p tcp -m multiport --dports 80,443,48588 -j ACCEPT;
ip6tables -t filter -A INPUT -p icmpv6 -j ACCEPT;
ip6tables -t filter -A INPUT -i lo -j ACCEPT;
ip6tables -t filter -P INPUT DROP;

ip6tables -t filter -P FORWARD DROP;
ip6tables -t filter -P OUTPUT ACCEPT;
