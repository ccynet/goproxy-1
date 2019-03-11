#!/bin/sh
GOPROXY_local_port=33441

echo 正在停止 dnsmasq
service stop_dnsmasq
echo 正在清除 dnsmasq_gfwlist 配置
rm /jffs/configs/dnsmasq.d/dnsmasq_gfwlist_ipset.conf.txt
echo 正在删除 ipset gfwlist
ipset -X gfwlist
echo 正在创建 ipset gfwlist
ipset -N gfwlist iphash
echo 正在复制 dnsmasq_gfwlist
cp dnsmasq_gfwlist_ipset.conf.txt /jffs/configs/dnsmasq.d/dnsmasq_gfwlist_ipset.conf.txt
echo 正在启动 dnsmasq
service start_dnsmasq

echo 正在清除 iptables GOPROXY
iptables -t nat -F GOPROXY
#iptables -t nat -X GOPROXY
echo 正在创建 iptables GOPROXY
iptables -t nat -N GOPROXY

#远程VPS
echo 正在设置 iptables 直连
iptables -t nat -A GOPROXY -d 149.248.13.19 -j RETURN
iptables -t nat -A GOPROXY -d 139.180.134.14 -j RETURN
iptables -t nat -A GOPROXY -d 139.162.105.151 -j RETURN

#其他直连
iptables -t nat -A GOPROXY -d 45.32.77.140 -j RETURN

#本地地址
echo 正在设置 iptables 本地
iptables -t nat -A GOPROXY -d 0.0.0.0/8 -j RETURN
iptables -t nat -A GOPROXY -d 10.0.0.0/8 -j RETURN
iptables -t nat -A GOPROXY -d 127.0.0.0/8 -j RETURN
iptables -t nat -A GOPROXY -d 169.254.0.0/16 -j RETURN
iptables -t nat -A GOPROXY -d 172.16.0.0/12 -j RETURN
iptables -t nat -A GOPROXY -d 192.168.0.0/16 -j RETURN
iptables -t nat -A GOPROXY -d 224.0.0.0/4 -j RETURN
iptables -t nat -A GOPROXY -d 240.0.0.0/4 -j RETURN

#代理
echo 正在加载xt_set
modprobe xt_set
#GFWLIST
echo 正在设置 iptables gfwlist
#iptables -t nat -A GOPROXY -p tcp -m set --match-set gfwlist dst -j REDIRECT --to-port $GOPROXY_local_port
#iptables -t nat -A PREROUTING -p tcp -m set --match-set gfwlist dst -j REDIRECT --to-ports $GOPROXY_local_port
#iptables -t nat -A OUTPUT -p tcp -m set --match-set gfwlist dst -j REDIRECT --to-ports $GOPROXY_local_port
iptables -t nat -A GOPROXY -p tcp --dport 80 -m set --match-set gfwlist dst -j REDIRECT --to-ports $GOPROXY_local_port
iptables -t nat -A GOPROXY -p tcp --dport 443 -m set --match-set gfwlist dst -j REDIRECT --to-ports $GOPROXY_local_port


#全局，不要时请关闭
#iptables -t nat -A GOPROXY -p tcp --dport 80 -j REDIRECT --to-ports $GOPROXY_local_port
#iptables -t nat -A GOPROXY -p tcp --dport 443 -j REDIRECT --to-ports $GOPROXY_local_port

echo 正在设置 iptables 其他
#Apply the rules to nat client
iptables -t nat -A PREROUTING -p tcp -j GOPROXY
# Apply the rules to localhost
iptables -t nat -A OUTPUT -p tcp -j GOPROXY
