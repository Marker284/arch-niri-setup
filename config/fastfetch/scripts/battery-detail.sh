#!/usr/bin/env bash
# Батарея: динамическая иконка по уровню заряда + расчёт мощности/времени.

batt_icon() {
    local pct="$1" charging="$2"
    if [ "$charging" = "1" ]; then echo "󰂄"; return; fi
    if   [ "$pct" -ge 95 ]; then echo "󰁹"
    elif [ "$pct" -ge 85 ]; then echo "󰂁"
    elif [ "$pct" -ge 75 ]; then echo "󰂀"
    elif [ "$pct" -ge 65 ]; then echo "󰁿"
    elif [ "$pct" -ge 55 ]; then echo "󰁾"
    elif [ "$pct" -ge 45 ]; then echo "󰁽"
    elif [ "$pct" -ge 35 ]; then echo "󰁼"
    elif [ "$pct" -ge 25 ]; then echo "󰁻"
    elif [ "$pct" -ge 15 ]; then echo "󰁺"
    else echo "󰂎"
    fi
}

for bat in /sys/class/power_supply/BAT*; do
    [ -d "$bat" ] || continue

    status=$(cat "$bat/status" 2>/dev/null | tr -d '\n')
    capacity=$(cat "$bat/capacity" 2>/dev/null)
    cycles=$(cat "$bat/cycle_count" 2>/dev/null)

    power_uw=$(cat "$bat/power_now" 2>/dev/null)
    if [ -z "$power_uw" ] || [ "$power_uw" = "0" ]; then
        v=$(cat "$bat/voltage_now" 2>/dev/null)
        c=$(cat "$bat/current_now" 2>/dev/null)
        if [ -n "$v" ] && [ -n "$c" ]; then
            power_uw=$(awk "BEGIN{printf \"%.0f\", ($v/1000000)*($c/1000000)*1000000}")
        fi
    fi

    energy_now=$(cat "$bat/energy_now" 2>/dev/null)
    energy_full=$(cat "$bat/energy_full" 2>/dev/null)

    charging_flag=0
    [ "$status" = "Charging" ] && charging_flag=1
    icon=$(batt_icon "${capacity:-0}" "$charging_flag")

    line=""
    case "$status" in
        "Discharging")
            watts=$(awk "BEGIN{printf \"%.1f\", $power_uw/1000000}" 2>/dev/null)
            if [ -n "$power_uw" ] && [ "$power_uw" -gt 0 ] 2>/dev/null && [ -n "$energy_now" ]; then
                hours=$(awk "BEGIN{printf \"%.2f\", $energy_now/$power_uw}")
                h=$(awk "BEGIN{printf \"%d\", $hours}")
                m=$(awk "BEGIN{printf \"%d\", ($hours-$h)*60}")
                line="${icon} Discharging - ${capacity}% (${watts}W draw, ~${h}h ${m}m left) (cycles: ${cycles})"
            else
                line="${icon} Discharging - ${capacity}% (cycles: ${cycles})"
            fi
            ;;
        "Charging")
            watts=$(awk "BEGIN{printf \"%.1f\", $power_uw/1000000}" 2>/dev/null)
            if [ -n "$power_uw" ] && [ "$power_uw" -gt 0 ] 2>/dev/null && [ -n "$energy_now" ] && [ -n "$energy_full" ]; then
                remaining=$((energy_full - energy_now))
                hours=$(awk "BEGIN{printf \"%.2f\", $remaining/$power_uw}")
                h=$(awk "BEGIN{printf \"%d\", $hours}")
                m=$(awk "BEGIN{printf \"%d\", ($hours-$h)*60}")
                line="${icon} Charging - ${capacity}% (${watts}W, ~${h}h ${m}m to full) (cycles: ${cycles})"
            else
                line="${icon} Charging - ${capacity}% (cycles: ${cycles})"
            fi
            ;;
        "Full")
            line="${icon} Full - ${capacity}% (cycles: ${cycles})"
            ;;
        "Not charging")
            line="${icon} Idle (charge limited) - ${capacity}% (cycles: ${cycles})"
            ;;
        "")
            line="${icon} Not in use - ${capacity}% (cycles: ${cycles})"
            ;;
        *)
            line="${icon} ${status} - ${capacity}% (cycles: ${cycles})"
            ;;
    esac

    echo "$line"
done
