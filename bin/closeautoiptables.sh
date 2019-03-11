#!/bin/sh
service stop_dnsmasq
rm /jffs/configs/dnsmasq.d/dnsmasq_gfwlist_ipset.conf.txt
iptables -t nat -F GOPROXY
service start_dnsmasq
