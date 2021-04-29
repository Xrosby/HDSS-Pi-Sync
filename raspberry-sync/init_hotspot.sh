#Install and update Raspbian
apt -y update
apt -y upgrade

#Install git and clone sync code
apt install -y git
git clone https://github.com/Xrosby/HDSS-Pi-Sync.git

#Install hostapd and dsnmasq
apt -y install hostapd

systemctl unmask hostapd
systemctl enable hostapd

apt -y install dnsmasq



#Turn off hostapd and dsnmasq to make it possible to edit configuration files
systemctl stop hostapd
systemctl stop dnsmasq

#Configure a static IP for the wlan0 interface
echo "interface wlan0
    static ip_address=192.168.4.1/24" >> /etc/dhcpcd.conf

#Create backup of original dnsmasq config file
mv /etc/dnsmasq.conf /etc/dnsmasq.conf.orig



# add content to DNSMASQ file
echo "interface=wlan0
dhcp-range=192.168.4.2,192.168.4.100,255.255.255.0,24h
domain=wlan
address=/gw.wlan/192.168.4.1" >> /etc/dnsmasq.conf


#Append configuration to access point host software (hostapd) config file
echo "country_code=DK
interface=wlan0
ssid=hdssbandimpi
hw_mode=g
channel=7
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
driver=nl80211
wpa_passphrase=hdssbandim123
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP" >> /etc/hostapd/hostapd.conf


#Point to the hostapd config file
# Assign the filename
truncate -s 0 /etc/default/hostapd
echo 'DAEMON_CONF="/etc/hostapd/hostapd.conf"' >> /etc/default/hostapd


#Create service for pisync server
echo "[Unit]
Description=Sync and backup server for Bandim HDSS data collection tablets
After=network.target

[Service]
ExecStart=/usr/bin/python3 HDSS-Pi-Sync/raspberry-sync/__init__.py
WorkingDirectory=/home/pi
StandardOutput=inherit
StandardError=inherit
Restart=always
User=root

[Install]
WantedBy=multi-user.target" >> /etc/systemd/system/bandimsyncserver.service

systemctl daemon-reload
systemctl enable bandimsyncserver

#Reboot the pi and service will start
rfkill unblock wlan

reboot