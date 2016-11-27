# nddos
使用ruby写的一份抗D脚本，学习deflate

# 教程
作者：莫粒
 
描述：

该脚本用于检测ip的连接数量，超过设定的数量就添加到iptables中屏蔽
 
使用
：
=> 使用crontab定时检测

=> */1 * * * * ruby ddos.rb  >/dev/null 2>&1

=> 上面是1分钟执行一次检测

=> 每隔24小时取消屏蔽的IP

=> 0 0 * * *  ruby ddos.rb --unban >/dev/null 2>&1
