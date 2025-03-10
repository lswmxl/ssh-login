#!/bin/bash

# 定义路径
SCRIPT_URL="https://raw.githubusercontent.com/lswmxl/ssh-login/refs/heads/master/ssh_login.sh"
SCRIPT_PATH="/home/ssh_login.sh"
CONFIG_PATH="/home/ssh_login.conf"

# 让用户输入 Telegram 机器人 TOKEN 和 Chat ID
read -p "请输入 Telegram 机器人 TOKEN: " TOKEN
read -p "请输入 Telegram Chat ID: " CHAT_ID

# 下载 ssh_notify.sh
curl -s -L -o $SCRIPT_PATH $SCRIPT_URL

# 检查是否下载成功
if [ ! -f "$SCRIPT_PATH" ]; then
    echo "❌ 下载失败，请检查 URL 是否正确。"
    exit 1
fi

# 赋予执行权限

chmod 555 $SCRIPT_PATH

# 写入 TOKEN 和 CHAT_ID 到配置文件
echo "TOKEN=$TOKEN" > $CONFIG_PATH
echo "CHAT_ID=$CHAT_ID" >> $CONFIG_PATH

# 启动 ssh_notify.sh
nohup $SCRIPT_PATH >/dev/null 2>&1 &

# 添加开机自启
if ! grep -q "$SCRIPT_PATH" /etc/profile; then
    echo "nohup $SCRIPT_PATH >/dev/null 2>&1 &" >> /etc/profile
fi

echo "✅ 安装完成！SSH登陆通知已开启！"

exit 0