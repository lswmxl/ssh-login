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

# 获取远程 IP 地址的地理位置（使用 ip-api.com）
LOCATION=$(curl -s "https://ipinfo.io/$SSH_CLIENT_IP/json" | \
    awk -F'"' '
    /"country"/ {country=$4}
    /"region"/ {region=$4}
    /"city"/ {city=$4}
    END {print country, region, city}')

# 获取服务器的公网 IP
SERVER_PUBLIC_IP=$(curl -s https://api.ipify.org)  # 使用 ipify 获取公网 IP

# 生成消息内容
MESSAGE="🔔 SSH 登录通知%0A👤 用户: $USER%0A🖥 服务器: $HOSTNAME%0A🌐 服务器IP:$IP_ADDRESS%0A🌐 服务器IP: $SERVER_PUBLIC_IP%0A📡 登录IP: $SSH_CLIENT_IP%0A📍 位置: $LOCATION"
# 发送到 Telegram
URL="https://api.telegram.org/bot$TOKEN/sendMessage"
curl -s -X POST $URL -d chat_id=$CHAT_ID -d text="$MESSAGE" >/dev/null 2>&1 &
disown -a

exit 0