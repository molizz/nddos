#!/usr/bin/ruby

# 作者：
#   锐壳科技 - www.rkidc.net - 莫粒
# 描述：
#   该脚本用于检测ip的连接数量，超过设定的数量就添加到iptables中屏蔽
# 使用：
# => 使用crontab定时检测
# => */1 * * * * ruby ddos.rb  >/dev/null 2>&1
# => 上面是1分钟执行一次检测

# => 每隔24小时取消屏蔽的IP
# => 0 0 * * *  ruby ddos.rb --unban >/dev/null 2>&1


# 每个IP的最大连接数，超过这个连接数就添加到iptables中屏蔽
NO_OF_CONNECTIONS = 50

# 白名单， 一行一个
IGNORE_IP_LIST = """
127.0.0.1
"""

# 临时目录
TMP_DIR = "/tmp/ddos"
TMP_BAN_FILE = "#{TMP_DIR}/ban.ip"
LOG_FILE = "./ddos.log"

def log(text)
  File.open(LOG_FILE, "a+") do |f|
    str ="#{Time.now} - #{text}\n"
    f.write str
    puts str
  end
end

def add_ban(ip,count)
  # 是否在白名单中
  return if IGNORE_IP_LIST.split.include? ip
  # 如果该ip已屏蔽过，则不再屏蔽
  return if baned? ip
  `/sbin/iptables -I INPUT -s #{ip}  -j DROP`
  File.open(TMP_BAN_FILE, "a+") do |f|
    f.write "#{ip}\n"
  end
  log("IP: #{ip} COUNT: #{count}  BANED!!")
end

def del_ban
  return if !File.exist? TMP_BAN_FILE
  File.readlines(TMP_BAN_FILE).each do |ip|
    `/sbin/iptables -D INPUT -s #{ip.strip} -j DROP`
    log "delete ban: #{ip}"
  end
  File.delete TMP_BAN_FILE
end

def baned?(ip)
  ip = "#{ip}\n"
  return false if !File.exist? TMP_BAN_FILE
  if @ban_ips.nil?
    @ban_ips = File.readlines(TMP_BAN_FILE)
  end
  @ban_ips.include? ip
end

if !File.directory?(TMP_DIR)
  `mkdir #{TMP_DIR}`
end

if ARGV.first == "--unban"
  puts "start delete baned ip"
  del_ban
else
  puts "start ban ip"
  result = `netstat -ntu | awk '{print $5}' | cut -d: -f1 | sort | uniq -c | sort -nr`

  lines = result.split("\n")

  puts "-----------------------------"

  lines.each do |line|
    count_ip = line.strip.split
    count = count_ip.first.to_i
    ip = count_ip.last
    if count >= NO_OF_CONNECTIONS
      add_ban ip, count
    end
  end
end
