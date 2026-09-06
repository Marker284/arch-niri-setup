#!/usr/bin/env bash
# WiFi: SSID, скорость, сигнал, с динамической иконкой уровня сигнала.
# Использует nmcli (обычно уже стоит вместе с NetworkManager).

wifi_icon() {
    local sig="$1"
    if   [ "$sig" -ge 80 ] 2>/dev/null; then echo "󰤨"
    elif [ "$sig" -ge 55 ] 2>/dev/null; then echo "󰤥"
    elif [ "$sig" -ge 30 ] 2>/dev/null; then echo "󰤢"
    elif [ "$sig" -gt 0 ] 2>/dev/null;  then echo "󰤟"
    else echo "󰤮"
    fi
}

# Активное wifi-подключение: SSID, сигнал, скорость
active=$(nmcli -t -f active,ssid,signal,rate dev wifi 2>/dev/null | grep '^yes' | head -1)

if [ -z "$active" ]; then
    echo "󰤮 Not connected"
    exit 0
fi

ssid=$(echo "$active" | cut -d':' -f2)
signal=$(echo "$active" | cut -d':' -f3)
rate=$(echo "$active" | cut -d':' -f4)

icon=$(wifi_icon "${signal:-0}")

echo "${icon} ${ssid} - ${signal}% (${rate})"
