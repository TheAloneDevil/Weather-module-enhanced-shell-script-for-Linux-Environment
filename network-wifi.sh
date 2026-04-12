#!/bin/bash

# Get WiFi status with actual download speed

SPEED_FILE="$HOME/.cache/wifi-speed.data"

CONNECTING_ICONS=("󰤯" "󰤟" "󰤢" "󰤥" "󰤨")

readable() {
    local bytes=$1
    local kib=$((bytes >> 10))
    if [ $kib -lt 0 ]; then
        echo "? K"
    elif [ $kib -gt 1024 ]; then
        local mib_int=$((kib >> 10))
        local mib_dec=$((kib % 1024 * 976 / 10000))
        if [ "$mib_dec" -lt 10 ]; then
            mib_dec="0${mib_dec}"
        fi
        echo "${mib_int}.${mib_dec} MB/s"
    else
        echo "${kib} KB/s"
    fi
}

device_state=$(nmcli -t -f DEVICE,STATE dev status | grep "^wlan0:" | cut -d: -f2)
device_conn=$(nmcli -t -f DEVICE,CONNECTION dev status | grep "^wlan0:" | cut -d: -f2)

if [[ "$device_state" == "connecting" || "$device_state" == "connecting ("* ]]; then
    # Cycle twice per second (every half-second)
    idx=$(( ($(date +%s) * 2) % 5 ))
    icon="${CONNECTING_ICONS[$idx]}"
    conn_name=$(nmcli -t -f DEVICE,CONNECTION dev status | grep "^wlan0:" | cut -d: -f2)
    if [ -n "$conn_name" ]; then
        echo "%{F-}%{T29}%{F#854785}$icon%{T-}%{F-}  Connecting to $conn_name..."
    else
        echo "%{F-}%{T29}%{F#854785}$icon%{T-}%{F-}  Connecting..."
    fi
    exit 0
fi

connected=$(nmcli -t -f NAME,DEVICE connection show --active 2>/dev/null | grep ":wlan0$" | cut -d: -f1)

if [ -n "$connected" ]; then
    if ping -c 1 -W 2 8.8.8.8 >/dev/null 2>&1; then
        icon=""
    else
        icon="󰤣"
    fi
    
    wifi_info=$(nmcli -t -f SSID,RATE dev wifi list ifname wlan0 2>/dev/null | grep "^$connected:" | head -1)
    essid=$(echo "$wifi_info" | cut -d: -f1)
    
    curr_bytes=$(cat /sys/class/net/wlan0/statistics/rx_bytes 2>/dev/null)
    curr_time=$(date +%s)
    
    if [ -f "$SPEED_FILE" ]; then
        read -r prev_bytes prev_time < "$SPEED_FILE"
        diff_bytes=$((curr_bytes - prev_bytes))
        diff_time=$((curr_time - prev_time))
        
        if [ $diff_time -gt 0 ]; then
            speed=$((diff_bytes / diff_time))
            speed_str=$(readable $speed)
            echo "%{F-}%{T29}%{F#854785}$icon%{T-}%{F-}  $essid %{F#6C77BB}%{F-} $speed_str"
        else
            echo "%{F-}%{T29}%{F#854785}$icon%{T-}%{F-}  $essid"
        fi
    else
        echo "%{F-}%{T29}%{F#854785}$icon%{T-}%{F-}  $essid"
    fi
    
    echo "$curr_bytes $curr_time" > "$SPEED_FILE"
else
    rm -f "$SPEED_FILE"
    echo "%{F-}%{T29}%{F#854785}󰖪%{T-}%{F-}  Offline"
fi
