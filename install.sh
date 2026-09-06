#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════════
#  arch-niri-setup — развёртывание на чистой Arch-системе
#  Deploys this niri + Noctalia setup on a fresh Arch install.
#
#  Использование / Usage:
#      ./install.sh                 # пакеты + конфиги / packages + configs
#      ./install.sh --no-packages   # только конфиги / configs only
#      ./install.sh --wallpapers    # ещё и скачать набор обоев / also fetch wallpapers
#      ./install.sh --dry-run       # показать, что будет сделано / preview only
#
#  Конфиги подключаются симлинками на этот репозиторий: правишь файл в
#  ~/.config — правится файл в репозитории, и его сразу видно в git status.
#  Configs are symlinked from this repo, so edits show up in git status.
# ═══════════════════════════════════════════════════════════════════════════
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"
BACKUP="$CONFIG/_backup-arch-niri-setup-$(date +%Y%m%d-%H%M%S)"

DO_PACKAGES=1
DO_WALLPAPERS=0
DRY_RUN=0

for arg in "$@"; do
    case "$arg" in
        --no-packages) DO_PACKAGES=0 ;;
        --wallpapers)  DO_WALLPAPERS=1 ;;
        --dry-run)     DRY_RUN=1 ;;
        -h | --help)
            sed -n '2,17p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
            exit 0
            ;;
        *)
            echo "Неизвестный аргумент / unknown argument: $arg" >&2
            exit 1
            ;;
    esac
done

c_ok=$'\033[32m'; c_warn=$'\033[33m'; c_err=$'\033[31m'; c_hd=$'\033[1;36m'; c_off=$'\033[0m'
say()  { printf '%s\n' "$*"; }
head_() { printf '\n%s── %s%s\n' "$c_hd" "$*" "$c_off"; }
ok()   { printf '  %s✓%s %s\n' "$c_ok" "$c_off" "$*"; }
warn() { printf '  %s!%s %s\n' "$c_warn" "$c_off" "$*"; }
die()  { printf '%sОшибка / error:%s %s\n' "$c_err" "$c_off" "$*" >&2; exit 1; }
run()  { if [ "$DRY_RUN" = 1 ]; then printf '  [dry-run] %s\n' "$*"; else "$@"; fi; }

# ── Проверки / preflight ───────────────────────────────────────────────────
head_ "Проверки / preflight"
command -v pacman >/dev/null 2>&1 || die "это не Arch — нет pacman / not an Arch system"
[ "$(id -u)" -ne 0 ] || die "запускай от обычного пользователя, не от root / run as your user, not root"
ok "Arch, пользователь $(id -un)"
[ "$DRY_RUN" = 1 ] && warn "режим --dry-run: ничего не меняется / nothing will be changed"

# ── Пакеты / packages ──────────────────────────────────────────────────────
PACKAGES=(
    # компози­тор и оболочка / compositor and shell
    niri noctalia xwayland-satellite
    # терминал и шрифты / terminal and fonts
    kitty ttf-jetbrains-mono-nerd inter-font
    # темизация GTK/Qt / GTK and Qt theming
    adw-gtk-theme nwg-look qt6ct papirus-icon-theme
    # порталы: скриншоты, демонстрация экрана / portals
    xdg-desktop-portal-gtk xdg-desktop-portal-gnome
    # железо и медиа / hardware and media
    brightnessctl playerctl wl-clipboard grim slurp swaybg
    # то, что красится по обоям / extra theme targets
    fastfetch btop
    # генерация PNG для темы Chrome / PNG generation for the Chrome theme
    python-pillow
)

if [ "$DO_PACKAGES" = 1 ]; then
    head_ "Пакеты / packages"
    missing=()
    for p in "${PACKAGES[@]}"; do
        pacman -Q "$p" >/dev/null 2>&1 || missing+=("$p")
    done
    if [ ${#missing[@]} -eq 0 ]; then
        ok "всё уже установлено / everything already installed"
    else
        say "  ставлю / installing: ${missing[*]}"
        run sudo pacman -S --needed --noconfirm "${missing[@]}"
        ok "готово / done"
    fi
else
    head_ "Пакеты пропущены (--no-packages) / packages skipped"
fi

# ── Конфиги / configs ──────────────────────────────────────────────────────
# «источник в репозитории» → «куда положить в ~/.config»
LINKS=(
    "niri/config.kdl:niri/config.kdl"
    "noctalia/config.toml:noctalia/config.toml"
    "noctalia/templates:noctalia/templates"
    "kitty/kitty.conf:kitty/kitty.conf"
    "fastfetch/config.jsonc:fastfetch/config.jsonc"
    "fastfetch/scripts:fastfetch/scripts"
    "autostart/nm-applet.desktop:autostart/nm-applet.desktop"
)

head_ "Конфиги / configs"
for pair in "${LINKS[@]}"; do
    src="$REPO/config/${pair%%:*}"
    dst="$CONFIG/${pair##*:}"
    [ -e "$src" ] || { warn "нет в репозитории / missing in repo: $src"; continue; }

    if [ -L "$dst" ] && [ "$(readlink -f "$dst")" = "$(readlink -f "$src")" ]; then
        ok "уже подключён / already linked: ${pair##*:}"
        continue
    fi

    if [ -e "$dst" ] || [ -L "$dst" ]; then
        run mkdir -p "$BACKUP/$(dirname "${pair##*:}")"
        run mv "$dst" "$BACKUP/${pair##*:}"
        warn "старый файл сохранён / backed up: ${pair##*:}"
    fi

    run mkdir -p "$(dirname "$dst")"
    run ln -s "$src" "$dst"
    ok "подключён / linked: ${pair##*:}"
done

# qt6ct.conf содержит абсолютный путь, поэтому он генерируется, а не линкуется.
# qt6ct.conf holds an absolute path, so it is generated rather than symlinked.
run mkdir -p "$CONFIG/qt6ct/colors"
if [ "$DRY_RUN" = 1 ]; then
    say "  [dry-run] сгенерировать / generate $CONFIG/qt6ct/qt6ct.conf"
else
    sed "s|@HOME@|$HOME|g" "$REPO/config/qt6ct/qt6ct.conf.in" > "$CONFIG/qt6ct/qt6ct.conf"
fi
ok "qt6ct.conf сгенерирован / generated"

run chmod +x "$REPO"/config/noctalia/templates/*.sh "$REPO"/config/fastfetch/scripts/*.sh

# ── Обои / wallpapers ──────────────────────────────────────────────────────
head_ "Обои / wallpapers"
WALLS="$HOME/Pictures/Wallpapers"
run mkdir -p "$WALLS"
if [ "$DO_WALLPAPERS" = 1 ]; then
    base="https://raw.githubusercontent.com/D3Ext/aesthetic-wallpapers/main/images"
    for f in astronaut-nord.png abstract.jpg anime_cafe_tokyonight.png arch-nord-dark.png \
             art-lake.png aurora_v02.png beach_landscape.png Doodle_Space_Nord.png \
             TokyoSimplistic.jpg 4k-ai-mountain.jpg; do
        [ -f "$WALLS/$f" ] && continue
        run curl -sfL --max-time 60 -o "$WALLS/$f" "$base/$f" && ok "$f" || warn "не скачалось / failed: $f"
    done
else
    if [ -z "$(ls -A "$WALLS" 2>/dev/null)" ]; then
        [ "$DRY_RUN" = 1 ] || cp /usr/share/noctalia/assets/noctalia-wallpaper.png "$WALLS/" 2>/dev/null || true
        warn "каталог пуст, положил обои Noctalia. Больше: ./install.sh --wallpapers"
        warn "directory was empty, added the Noctalia wallpaper. More: ./install.sh --wallpapers"
    else
        ok "$WALLS уже не пуст / not empty"
    fi
fi

# ── nm-applet ──────────────────────────────────────────────────────────────
# У Noctalia свой виджет сети; системный автозапуск nm-applet дал бы второй
# значок Wi-Fi в трее. Наш файл в ~/.config/autostart перекрывает системный.
head_ "nm-applet"
if pgrep -x nm-applet >/dev/null 2>&1; then
    run pkill -x nm-applet || true
    ok "остановлен, в niri больше не стартует / stopped, will not start in niri"
else
    ok "не запущен / not running"
fi

# ── Итог / next steps ──────────────────────────────────────────────────────
head_ "Что дальше / next steps"
cat <<EOF
  1. Перелогинься и выбери сессию «Niri» на экране входа.
     Log out and pick the "Niri" session at the login screen.

  2. Noctalia покажет окно приветствия — нажми «Get Started» мышкой.
     Noctalia shows a welcome dialog — click "Get Started".

  3. Подсказка по клавишам: Super+Shift+/
     Keybinding cheat sheet: Super+Shift+/

  4. Разово подключить темы, которые нельзя применить командой:
     One-time hookups for themes that cannot be applied from a script:
       • Chrome   chrome://extensions → Режим разработчика / Developer mode →
                  Загрузить распакованное / Load unpacked →
                  ~/.local/share/noctalia/google-chrome-theme
       • Telegram Настройки → Оформление → «Фон чата» → «Выбрать из файла» →
                  Settings → Appearance → Chat background → "Choose from file" →
                  ~/.config/telegram-desktop/themes/noctalia.tdesktop-theme

  Конфиги — симлинки на $REPO.
  Правь их где угодно, затем: git -C "$REPO" status
EOF
[ -d "$BACKUP" ] && say "" && warn "старые конфиги / previous configs: $BACKUP"
say ""
