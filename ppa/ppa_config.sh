#!/bin/bash
# ------------------------

APT_KEY="public.key"
DNS_FILE="/etc/hosts"
DOMAIN="ppa.cowarobot.com"
#PPA_IP=192.168.30.179
PPA_IP=118.25.144.84

if [[ "$1" != *.*.*.* ]]; then
  echo "WARNING: Please provide a valid ppa IP address as the first parameter."
fi

if [ `grep -c "${DOMAIN}" ${DNS_FILE}` -ne '0' ];then
    FROM_REG="^[0-9.]* ${DOMAIN}$"
    TO_STR="${PPA_IP} ${DOMAIN}"
    sed -i -E "s/${FROM_REG}/${TO_STR}/g" ${DNS_FILE}
else
    echo "${PPA_IP} ${DOMAIN}" >> ${DNS_FILE}
fi

echo "${PPA_IP} ${DOMAIN}"


apt-key add $APT_KEY
echo "deb http://$DOMAIN:40101/voyance focal main" | tee /etc/apt/sources.list.d/voyance.list
apt update
apt search voyance

#sudo crontab -e
#0 3 * * * apt update && apt install voyance
if crontab -l | grep "voyance"; then
    echo "crontab has been set."
else
    echo "0 3 * * * apt update && apt install voyance" >> /var/spool/cron/crontabs/$(whoami)
fi

echo "
[Unit]
Description=voyance update script
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/voyance-update.sh

[Install]
WantedBy=multi-user.target
" | tee /etc/systemd/system/voyance.service

cp voyance-update.sh /usr/local/bin/ && chmod +x /usr/local/bin/voyance-update.sh

systemctl daemon-reload
systemctl enable voyance.service
systemctl start voyance.service
systemctl status voyance.service

echo "Finish ."

