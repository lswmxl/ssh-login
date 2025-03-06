#!/bin/bash

CONFIG_FILE="/home/ssh_login.conf"

# 读取配置文件
if [ -f "$CONFIG_FILE" ]; then
    source $CONFIG_FILE
else
    echo "❌ 配置文件 $CONFIG_FILE 不存在！请检查。"
    exit 1
fi

# 确保 TOKEN 和 CHAT_ID 不为空
if [ -z "$TOKEN" ] || [ -z "$CHAT_ID" ]; then
    echo "❌ 配置文件中的 TOKEN 或 CHAT_ID 为空，请检查 $CONFIG_FILE！"
    exit 1
fi

# 获取 SSH 登录信息
USER=$(whoami)
HOSTNAME=$(hostname)
IP_ADDRESS=$(curl -s https://api.ipify.org)  # 获取公网 IP
SSH_CLIENT_IP=$(echo $SSH_CONNECTION | awk '{print $1}')  # 登录 IP

if [ -z "$SSH_CLIENT_IP" ]; then
    exit 0
fi

# 获取远程 IP 位置
LOCATION=$(curl -s "http://ip-api.com/json/$SSH_CLIENT_IP?lang=zh-CN" | \
    awk -F'"' '/"country"/ {country=$4} /"regionName"/ {region=$4} /"city"/ {city=$4} END {print country, region, city}')

# 生成消息
MESSAGE="🔔 SSH 登录通知\n👤 用户: $USER\n🖥 服务器: $HOSTNAME\n🌐 服务器公网 IP: $IP_ADDRESS\n📡 登录 IP: $SSH_CLIENT_IP\n📍 位置: $LOCATION"

# 发送到 Telegram
URL="https://api.telegram.org/bot$TOKEN/sendMessage"
curl -s -X POST $URL -d chat_id=$CHAT_ID -d text="$MESSAGE" >/dev/null 2>&1 &
disown -a

exit 0