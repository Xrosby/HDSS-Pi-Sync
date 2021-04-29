SSID="admin"
WPA_PASS="admin"

set_ap() {
    read -p "What is your SSID?    " ssid_input
    read -p "What is your WPA_PASS?    " wpa_input

    read -p "Are you sure your AP is ${ssid_input} with pass ${wpa_input}? (y/n)" answer
    if [ "$answer" = "y" ];
    then 
        SSID="${ssid_input}"
        WPA_PASS="${wpa_input}"
        echo "SSID: ${SSID}    WPA_PASS: ${WPA_PASS}"
    else 
        set_ap
    fi
}

set_ap
