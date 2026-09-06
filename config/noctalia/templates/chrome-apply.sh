#!/usr/bin/env bash
# Собирает тему Google Chrome из палитры Noctalia.
#
# Тема Chrome — это обычное распакованное расширение. Noctalia на каждой смене
# палитры перерисовывает manifest.json, скрипт докладывает рядом сплошные PNG
# (без них Chrome под Linux оставляет рамку и новую вкладку некрашеными) и
# поднимает version, чтобы кнопка «Обновить» в chrome://extensions подхватила
# изменения.
#
# Путь установки не меняется, поэтому «Загрузить распакованное расширение»
# нужно сделать ровно один раз — дальше цвета едут сами.
#
# Дополнительно, если Chrome закрыт, скрипт кладёт в Preferences seed-цвет
# (browser.theme.user_color) — из него Chrome красит те места, до которых тема
# расширением не дотягивается. При запущенном Chrome Preferences не трогаем:
# он перезапишет файл своим состоянием при выходе.
#
# Использование: chrome-apply.sh <dark|light>
set -euo pipefail

log() { printf 'noctalia-chrome: %s\n' "$*" >&2; }

mode="${1:-}"
case "$mode" in
    dark | light) ;;
    *)
        # Аргумент не подставился — спросим у самой оболочки.
        mode=$(noctalia msg theme-mode-get 2>/dev/null | tr -d '[:space:]')
        [ "$mode" = "light" ] || mode="dark"
        ;;
esac

xdg_config="${XDG_CONFIG_HOME:-$HOME/.config}"
xdg_cache="${XDG_CACHE_HOME:-$HOME/.cache}"
xdg_data="${XDG_DATA_HOME:-$HOME/.local/share}"

chrome_user_data="$xdg_config/google-chrome"
rendered_manifest="$xdg_cache/noctalia/google-chrome-theme/manifest.json"
theme_dir="$xdg_data/noctalia/google-chrome-theme"
note_file="$theme_dir/УСТАНОВКА.txt"

if [ ! -d "$chrome_user_data" ]; then
    log "профиль Google Chrome не найден ($chrome_user_data) — пропускаю"
    exit 0
fi

if [ ! -f "$rendered_manifest" ]; then
    log "ERROR: Noctalia не отрисовала manifest.json ($rendered_manifest)"
    exit 1
fi

command -v python3 >/dev/null 2>&1 || {
    log "ERROR: нужен python3"
    exit 1
}
python3 -c 'import PIL' 2>/dev/null || {
    log "ERROR: нужен python-pillow (sudo pacman -S python-pillow)"
    exit 1
}

chrome_is_running() {
    pgrep -u "$(id -u)" -x chrome >/dev/null 2>&1 ||
        pgrep -u "$(id -u)" -x google-chrome >/dev/null 2>&1 ||
        pgrep -u "$(id -u)" -f '/opt/google/chrome/chrome' >/dev/null 2>&1
}

# ── Собираем расширение-тему ───────────────────────────────────────────────
mkdir -p "$theme_dir/images"
NOCTALIA_MODE="$mode" \
    RENDERED_MANIFEST="$rendered_manifest" \
    THEME_DIR="$theme_dir" \
    python3 - <<'PY'
import json
import os
from datetime import datetime, timezone
from pathlib import Path

from PIL import Image

rendered = Path(os.environ["RENDERED_MANIFEST"])
theme_dir = Path(os.environ["THEME_DIR"])
mode = os.environ["NOCTALIA_MODE"]

manifest = json.loads(rendered.read_text())
theme = manifest.setdefault("theme", {})
colors = theme["colors"]

theme.setdefault("properties", {})["ntp_logo_alternate"] = 1 if mode == "dark" else 0
# Chrome перезагружает распакованное расширение только при смене версии.
manifest["version"] = datetime.now(timezone.utc).strftime("1.%Y%m%d.%H%M%S")

theme["images"] = {
    "theme_frame": "images/theme_frame.png",
    "theme_frame_inactive": "images/theme_frame_inactive.png",
    "theme_frame_incognito": "images/theme_frame_incognito.png",
    "theme_toolbar": "images/theme_toolbar.png",
    "theme_ntp_background": "images/theme_ntp_background.png",
    "theme_tab_background": "images/theme_tab_background.png",
}

img_dir = theme_dir / "images"
img_dir.mkdir(parents=True, exist_ok=True)


def rgb(name):
    return tuple(int(c) for c in colors[name])


def write_png(name, color, size):
    Image.new("RGB", size, color).save(img_dir / name, "PNG")


write_png("theme_frame.png", rgb("frame"), (80, 60))
write_png("theme_frame_inactive.png", rgb("frame_inactive"), (80, 60))
write_png("theme_frame_incognito.png", rgb("frame_incognito"), (80, 60))
write_png("theme_toolbar.png", rgb("toolbar"), (320, 120))
write_png("theme_tab_background.png", rgb("frame"), (64, 64))
write_png("theme_ntp_background.png", rgb("ntp_background"), (1920, 1080))

(theme_dir / "manifest.json").write_text(json.dumps(manifest, indent=2) + "\n")
print(manifest["version"])
PY

log "тема собрана в $theme_dir"

# ── Seed-цвет в Preferences (только при закрытом Chrome) ───────────────────
if chrome_is_running; then
    log "Chrome запущен — Preferences не трогаю; новые цвета встанут после его перезапуска"
else
    scheme=2
    [ "$mode" = "light" ] && scheme=1

    shopt -s nullglob
    for prefs in "$chrome_user_data"/Default/Preferences "$chrome_user_data"/Profile\ */Preferences; do
        [ -f "$prefs" ] || continue
        CHROME_PREFS="$prefs" \
            CHROME_COLOR_SCHEME="$scheme" \
            THEME_MANIFEST="$theme_dir/manifest.json" \
            python3 - <<'PY' || log "не смог обновить $(dirname "$prefs")/Preferences"
import json
import os
import stat
from pathlib import Path

prefs = Path(os.environ["CHROME_PREFS"])
scheme = int(os.environ["CHROME_COLOR_SCHEME"])
manifest_path = Path(os.environ["THEME_MANIFEST"])

data = json.loads(prefs.read_text())
theme = data.setdefault("browser", {}).setdefault("theme", {})

user_color = theme.get("user_color")
colors = json.loads(manifest_path.read_text())["theme"]["colors"]
seed = colors.get("ntp_link") or colors.get("toolbar_button_icon")
if isinstance(seed, list) and len(seed) >= 3:
    r, g, b = int(seed[0]), int(seed[1]), int(seed[2])
    # Chrome хранит цвет как знаковое 32-битное SkColor (ARGB).
    sk = 0xFF000000 | (r << 16) | (g << 8) | b
    if sk >= 2**31:
        sk -= 2**32
    user_color = sk

changed = False
for key, value in (
    ("color_scheme", scheme),
    ("color_scheme2", scheme),
    ("user_color", user_color),
    ("user_color2", user_color),
):
    if value is not None and theme.get(key) != value:
        theme[key] = value
        changed = True

if changed:
    perms = stat.S_IMODE(prefs.stat().st_mode)
    tmp = prefs.with_name("Preferences.noctalia-tmp")
    tmp.write_text(json.dumps(data, separators=(",", ":"), ensure_ascii=False))
    os.chmod(tmp, perms)
    tmp.replace(prefs)
PY
    done
    shopt -u nullglob
    log "seed-цвет и режим ($mode) записаны в Preferences"
fi

# ── Разовая инструкция ─────────────────────────────────────────────────────
if [ ! -f "$note_file" ]; then
    cat >"$note_file" <<EOF
Тема Noctalia для Google Chrome — подключить один раз:

  1. Открой chrome://extensions
  2. Включи «Режим разработчика» (переключатель справа сверху)
  3. «Загрузить распакованное расширение» и выбери папку:
     $theme_dir

Дальше ничего делать не надо: Noctalia перезаписывает эту же папку при каждой
смене обоев. Новые цвета Chrome подхватывает при перезапуске — или сразу, если
нажать «Обновить» на карточке расширения в chrome://extensions.
EOF
    log "первый запуск — подключи тему один раз, инструкция в $note_file"
fi
