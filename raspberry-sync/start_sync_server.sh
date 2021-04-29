rfkill unblock wlan
systemctl hostapd restart
pip3 install -r _misc/requirements.txt
python3 __init__.py
