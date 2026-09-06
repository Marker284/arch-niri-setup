#!/usr/bin/env bash
# Возраст системы: дата установки Arch и сколько с неё прошло.
#
# Дату берём из времени создания корневой ФС (stat -c %W) — это мгновенно.
# Если ФС не хранит birth time (например XFS без ftype), откатываемся на первую
# строку pacman.log: её пишет pacstrap при установке.

epoch=$(stat -c %W / 2>/dev/null)

if [ -z "$epoch" ] || [ "$epoch" -le 0 ] 2>/dev/null; then
    first=$(head -n1 /var/log/pacman.log 2>/dev/null | sed -n 's/^\[\([^]]*\)\].*/\1/p')
    [ -n "$first" ] && epoch=$(date -d "$first" +%s 2>/dev/null)
fi

if [ -z "$epoch" ] || [ "$epoch" -le 0 ] 2>/dev/null; then
    echo "unknown"
    exit 0
fi

read -r iy im id <<<"$(date -d "@$epoch" '+%Y %-m %-d')"
read -r ny nm nd <<<"$(date '+%Y %-m %-d')"

years=$((ny - iy))
months=$((nm - im))
days=$((nd - id))

# Занимаем дни из предыдущего месяца, если ушли в минус.
if [ "$days" -lt 0 ]; then
    months=$((months - 1))
    days=$((days + $(date -d "$(date +%Y-%m-01) -1 day" +%d)))
fi
if [ "$months" -lt 0 ]; then
    years=$((years - 1))
    months=$((months + 12))
fi

age=""
[ "$years" -gt 0 ]  && age="${years}y"
[ "$months" -gt 0 ] && age="${age:+$age }${months}mo"
[ "$days" -gt 0 ]   && age="${age:+$age }${days}d"
[ -z "$age" ] && age="today"

printf '%s (%s)\n' "$(date -d "@$epoch" '+%d %b %Y')" "$age"
