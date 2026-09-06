#!/usr/bin/env bash
# Напоминает перезапустить Telegram, когда палитра действительно поменялась.
#
# Как это работает.
# Telegram Desktop, если тему подключить «из файла», запоминает ПУТЬ к нему и
# перечитывает файл при каждом старте приложения (так написано в официальной
# вики tdesktop). Путь у нас постоянный, значит подключение разовое, а дальше
# новые цвета подхватываются сами — при следующем запуске Telegram.
#
# Разовая настройка:
#   Telegram → Настройки → Оформление → блок «Фон чата» → «Выбрать из файла»
#   и указать   ~/.config/telegram-desktop/themes/noctalia.tdesktop-theme
#
# Применить прямо сейчас, не дожидаясь перезапуска, нельзя: у Telegram нет для
# этого ни ключа командной строки, ни IPC — файл в аргументах он понимает как
# «отправить в чат».
#
# Уведомление приходит только когда палитра реально изменилась. Совсем не нужно —
# добавь в блок environment в ~/.config/niri/config.kdl:
#   NOCTALIA_TELEGRAM_NOTIFY "0"
set -euo pipefail

theme="${XDG_CONFIG_HOME:-$HOME/.config}/telegram-desktop/themes/noctalia.tdesktop-theme"
stamp="${XDG_CACHE_HOME:-$HOME/.cache}/noctalia/telegram-palette.md5"

[ -f "$theme" ] || exit 0

# Хук вызывается на каждое применение шаблонов, а не только на смену обоев.
# Сравниваем содержимое, чтобы не сыпать одинаковыми уведомлениями.
mkdir -p "$(dirname "$stamp")"
now=$(md5sum <"$theme" | cut -d' ' -f1)
was=$(cat "$stamp" 2>/dev/null || true)
printf '%s\n' "$now" >"$stamp"
[ "$now" = "$was" ] && exit 0

[ "${NOCTALIA_TELEGRAM_NOTIFY:-1}" = "0" ] && exit 0

# Молчим, если Telegram не запущен: он и так стартует уже с новой палитрой.
pgrep -u "$(id -u)" -x Telegram >/dev/null 2>&1 ||
    pgrep -u "$(id -u)" -x telegram-desktop >/dev/null 2>&1 ||
    exit 0

noctalia msg notification-show \
    "Палитра Telegram обновлена" \
    "Новые цвета встанут при следующем запуске Telegram" \
    >/dev/null 2>&1 || true
