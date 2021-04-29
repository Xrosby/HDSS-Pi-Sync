#Install and update Raspbian
apt -y update
apt -y upgrade

#Install git and clone sync code
apt install -y git
git clone https://github.com/Xrosby/HDSS-Pi-Sync.git

apt install -y  python3-pip
#Install hostapd and dsnmasq
apt install -y hostapd

systemctl unmask hostapd
systemctl enable hostapd

apt install -y dnsmasq



#Turn off hostapd and dsnmasq to make it possible to edit configuration files
systemctl stop hostapd
systemctl stop dnsmasq

#Configure a static IP for the wlan0 interface
echo "hostname
clientid
persistent
option rapid_commit
option domain_name_servers, domain_name, domain_search, host_name
option classless_static_routes
option interface_mtu
require dhcp_server_identifier
slaac private

interface wlan0
    static ip_address=192.168.4.1/24" >> /etc/dhcpcd.conf

#Create backup of original dnsmasq config file
mv /etc/dnsmasq.conf /etc/dnsmasq.conf.old

# add content to DNSMASQ file
echo "interface=wlan0
dhcp-range=192.168.4.2,192.168.4.100,255.255.255.0,24h
domain=wlan
address=/gw.wlan/192.168.4.1" >> /etc/dnsmasq.conf


#Append configuration to access point host software (hostapd) config file
# moving the possibly existing file, so we don't append
mv /etc/hostapd/hostapd.conf /etc/hostapd/hostapd.conf.old 
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
# moving the possibly existing file, so we dont append
mv /etc/default/hostapd /etc/default/hostapd.old
echo 'DAEMON_CONF="/etc/hostapd/hostapd.conf"' >> /etc/default/hostapd



# SETTING UP NET FORWARDING
mv /etc/sysctl.d/routed-ap.conf /etc/sysctl.d/routed-ap.conf.old
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.d/routed-ap.conf

DEBIAN_FRONTEND=noninteractive apt install -y netfilter-persistent iptables-persistent

iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

netfilter-persistent save



#Create service for pisync server, moving the old one so we dont append to the service file
mv /etc/systemd/system/bandimsyncserver.service /etc/systemd/system/bandimsyncserver.service.old
echo "[Unit]
Description=Sync and backup server for Bandim HDSS data collection tablets
After=network.target

[Service]
ExecStart=/bin/bash start_sync_server.sh
WorkingDirectory=/home/pi/HDSS-Pi-Sync/raspberry-sync
StandardOutput=inherit
StandardError=inherit
Restart=always
User=root

[Install]
WantedBy=multi-user.target" >> /etc/systemd/system/bandimsyncserver.service

systemctl daemon-reload
systemctl enable bandimsyncserver

reboot