#!/bin/bash
set -euo pipefail

# Неинтерактивный режим + оставляем текущие конфиги (важно для sshd)
export DEBIAN_FRONTEND=noninteractive

echo "==> apt update"
apt update

echo "==> apt upgrade (оставляем текущие конфиги)"
apt upgrade -y -o Dpkg::Options::="--force-confold"

echo "==> Установка fail2ban и mc"
apt install -y fail2ban mc -o Dpkg::Options::="--force-confold"

echo "==> Включаем fail2ban в автозагрузку"
systemctl enable fail2ban

echo "==> Пишем /etc/fail2ban/jail.local"
cat > /etc/fail2ban/jail.local << 'EOF'
[sshd]
enabled   = true
maxretry  = 5
findtime  = 1h
bantime   = 1d
EOF

echo "==> Запускаем fail2ban"
systemctl start fail2ban

# Чтобы настройки точно применились
systemctl restart fail2ban

echo "==> Готово. Статус fail2ban:"
systemctl status fail2ban --no-pager -l
