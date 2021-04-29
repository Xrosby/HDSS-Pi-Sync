#Install and update Raspbian
apt-get update
apt-get upgrade

#Install hostapd and dsnmasq
apt-get install hostapd
apt-get install dnsmasq

#Turn off hostapd and dsnmasq to make it possible to edit configuration files
systemctl stop hostapd
systemctl stop dnsmasq

#Create configuration files for dhcpcd
touch /etc/dhcpcd.conf

#Configure a static IP for the wlan0 interface
echo "interface wlan0
static ip_address=192.168.0.10/24
denyinterfaces eth0
denyinterfaces wlan0" >> /etc/dhcpcd.conf

#Create backup of original dnsmasq config file
mv /etc/dnsmasq.conf /etc/dnsmasq.orig

#Create new dnsmasq file
touch /etc/dnsmasq.conf

#Append new lines to dsnmasq config
echo "interface=wlan0
dhcp-range=192.168.0.11,192.168.0.30,255.255.255.0,24h" >> /etc/dnsmasq.conf

#Create the access point host software configuration file (hostapd)
touch /etc/hostapd/hostapd.conf

#Append configuration to access point host software (hostapd) config file

echo "Name the AP SSID (Name of the wifi network)"
read SSID
echo "Provide a password for the access point"
read WPA_PASS

echo "interface=wlan0
bridge=br0
hw_mode=g
channel=7
wmm_enabled=0
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
ssid="${SSID}"
wpa_passphrase=${WPA_PASS}" >> /etc/hostapd/hostapd.conf

#Point to the hostapd config file
# Assign the filename
filename="/etc/default/hostapd"

# Take the search string
read -p "#DAEMON_CONF=\"\"" search

# Take the replace string
read -p "DAEMON_CONF=\"/etc/hostapd/hostapd.conf\"" replace

if [[ $search != "" && $replace != "" ]]; then
sed -i "s/$search/$replace/" $filename
fi

#Set up traffic forwarding
# Assign the filename
#filename_f="/etc/sysctl.conf"

# Take the search string
#read -p "#net.ipv4.ip_forward=1" search_f

# Take the replace string
#read -p "net.ipv4.ip_forward=1" replace_f

#if [[ $search_f != "" && $replace_f != "" ]]; then
#sed -i "s/$search_f/$replace_f/" $filename_f
#fi

#Add a new iptables rule
#iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
#sh -c "iptables-save > /etc/iptables.ipv4.nat"
#iptables-restore < /etc/iptables.ipv4.nat

#Enable internet connection
#apt-get install bridge-utils
#brctl addbr br0
#brctl addif br0 eth0


#echo "auto br0
#iface br0 inet manual
#bridge_ports eth0 wlan0" >> /etc/network/interfaces


