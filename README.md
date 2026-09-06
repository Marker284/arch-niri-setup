<div align="center">

# arch-niri-setup

**Скроллящийся тайлинг на Arch: niri + Noctalia Shell, где вся система перекрашивается под обои.**

[![Arch Linux](https://img.shields.io/badge/Arch_Linux-1793D1?style=for-the-badge&logo=arch-linux&logoColor=white)](https://archlinux.org)
[![Wayland](https://img.shields.io/badge/Wayland-FFBC00?style=for-the-badge&logo=wayland&logoColor=black)](https://wayland.freedesktop.org)
[![niri](https://img.shields.io/badge/niri-26.04-7FC8FF?style=for-the-badge)](https://github.com/YaLTeR/niri)
[![Noctalia](https://img.shields.io/badge/Noctalia-5.0-8B7CF6?style=for-the-badge)](https://noctalia.dev)
[![kitty](https://img.shields.io/badge/kitty-0.48-52C7B8?style=for-the-badge)](https://sw.kovidgoyal.net/kitty/)
[![License](https://img.shields.io/badge/license-MIT-4CAF50?style=for-the-badge)](LICENSE)

**Русский** · [English](README.en.md)

</div>

---

## Что это

Конфигурация рабочего окружения на **niri** — вейланд-композиторе со скроллящимся
тайлингом, и **Noctalia Shell** — оболочке, которая рисует бар, док, лаунчер,
уведомления, обои и экран блокировки.

Главное: **палитра генерируется из текущих обоев** и разъезжается по всей системе —
по самой оболочке, рамкам окон niri, терминалу, GTK, Qt/KDE, btop, Telegram и Chrome.
Поменял обои — перекрасилось всё.

Ставится **рядом с существующей средой**, не вместо неё: niri появляется отдельным
пунктом на экране входа, Plasma/GNOME остаются на месте.

## Стек

| Роль | Что |
|---|---|
| Композитор | [niri](https://github.com/YaLTeR/niri) — скроллящийся тайлинг |
| Оболочка | [Noctalia](https://noctalia.dev) 5 — бар, док, лаунчер, уведомления, локскрин, polkit-агент |
| Терминал | [kitty](https://sw.kovidgoyal.net/kitty/) |
| Лаунчер | встроенный в Noctalia, сеткой иконок как Launchpad в macOS |
| Тема GTK | `adw-gtk3-dark` + сгенерированный `noctalia.css` |
| Тема Qt/KDE | `kdeglobals` из шаблона `kcolorscheme` |
| X11-приложения | `xwayland-satellite` (niri поднимает сам) |
| Портал | `xdg-desktop-portal-gnome` — скриншоты и демонстрация экрана |

## Установка

```bash
git clone https://github.com/Marker284/arch-niri-setup.git ~/arch-niri-setup
cd ~/arch-niri-setup
./install.sh
```

| Флаг | Что делает |
|---|---|
| *(без флагов)* | ставит пакеты и подключает конфиги |
| `--no-packages` | только конфиги |
| `--wallpapers` | ещё и скачивает набор обоев |
| `--dry-run` | показывает, что будет сделано, ничего не меняя |

Конфиги подключаются **симлинками** на этот репозиторий. Значит правки в
`~/.config/niri/config.kdl` — это правки в репозитории, и их сразу видно
в `git status`. Существующие файлы перед этим уезжают в
`~/.config/_backup-arch-niri-setup-*`.

После установки — перелогиниться и выбрать сессию **Niri**.

## Структура

```
config/
├── niri/config.kdl              композитор: клавиши, окна, ввод, блюр
├── noctalia/
│   ├── config.toml              бар, док, лаунчер, тема, обои
│   └── templates/               свои шаблоны: Telegram и Chrome
├── kitty/kitty.conf             терминал
├── fastfetch/                   config.jsonc + скрипты модулей
├── qt6ct/qt6ct.conf.in          шаблон (в нём абсолютный путь, потому не симлинк)
└── autostart/nm-applet.desktop  гасит nm-applet в niri, чтобы не было двух Wi-Fi
docs/cheatsheet.ru.md            подробная шпаргалка
install.sh
```

Сгенерированное в репозиторий не попадает: `noctalia.kdl`, `themes/noctalia.conf`,
`noctalia.css`, `kdeglobals`, `qt6ct/colors/` — всё это Noctalia пересобирает сама.

## Клавиши

`Mod` = `Super` (Win). Полный список внутри системы — `Super+Shift+/`.

| | |
|---|---|
| `Super+Space` | **Launchpad** — сетка приложений и поиск |
| `Super+Enter` | терминал |
| `Super+E` / `Super+B` | файлы / браузер |
| `Super+Q` | закрыть окно |
| `Super+O` | обзор рабочих столов (можно сразу печатать — начнётся поиск) |
| `Super+←/→` или `H/L` | колонка левее / правее |
| `Super+↑/↓` или `K/J` | окно выше / ниже в колонке |
| `Super+R` | циклом менять ширину колонки |
| `Super+F` / `Super+Shift+F` | развернуть колонку / полный экран |
| `Super+1…9` | рабочий стол |
| `Super+S` / `Super+V` / `Super+W` | центр управления / буфер обмена / обои |
| `Super+,` | настройки Noctalia |
| `Super+Alt+L` | заблокировать экран |
| `Print` | скриншот области |

Раскладка переключается **Caps Lock**.

Полная таблица — в [docs/cheatsheet.ru.md](docs/cheatsheet.ru.md).

## Как работает перекраска под обои

Меняешь обои (`Super+W`) → Noctalia вытаскивает палитру из картинки и
прогоняет её через шаблоны:

| Куда | Как |
|---|---|
| оболочка | бар, док, лаунчер, уведомления — сразу |
| niri | цвет рамки активного окна (`noctalia.kdl`) — сразу |
| kitty | 16 ANSI-цветов и фон, живые окна перекрашиваются по `SIGUSR1` |
| GTK 3/4 | `~/.config/gtk-*/noctalia.css` — при следующем запуске программы |
| Qt / KDE | `kdeglobals`, шаблон `kcolorscheme` |
| btop | тема |
| Telegram | `.tdesktop-theme` — подхватывается при запуске Telegram |
| Chrome | тема-расширение — по кнопке «Обновить» или при перезапуске |

Схема генерации задаётся в `[theme] wallpaper_scheme`. Здесь стоит `vibrant` —
из пяти доступных только у неё ANSI-цвета в терминале получаются заметно
различимыми, остальные сливают их в один оттенок.

## Разовые действия

Две программы нельзя перекрасить полностью автоматически — у них нет для этого API.
Настраивается один раз, дальше работает само.

**Chrome.** `chrome://extensions` → Режим разработчика → «Загрузить распакованное
расширение» → `~/.local/share/noctalia/google-chrome-theme`.
Дальше папка перезаписывается сама; новые цвета встают при перезапуске браузера
или сразу по кнопке «Обновить» на карточке расширения. Автоматизировать эту кнопку
нельзя: перезагрузчики расширений работают через `chrome.management`, а он не
перечитывает `manifest.json` — а тема целиком в нём.

**Telegram.** Настройки → Оформление → блок «Фон чата» → «Выбрать из файла» →
`~/.config/telegram-desktop/themes/noctalia.tdesktop-theme`.
Подключённую так тему Telegram запоминает **по пути к файлу** и перечитывает при
каждом запуске — поэтому дальше цвета едут сами. Применить на лету нельзя: файл в
аргументах командной строки Telegram понимает как «отправить в чат».

## Добавить свои программы

В каталоге сообщества Noctalia больше 60 готовых шаблонов — Discord, Spotify,
VS Code, Steam, Obsidian, neovim, rofi, yazi, zen-browser и другие:

```toml
[theme.templates]
enable_community_templates = true
community_ids              = ["discord", "vscode", "spicetify"]
```

Список: `curl -s https://api.noctalia.dev/templates | python3 -m json.tool | grep name`

## Благодарности

* [YaLTeR/niri](https://github.com/YaLTeR/niri)
* [noctalia-dev/noctalia-shell](https://github.com/noctalia-dev/noctalia-shell)
* шаблон Telegram и основа шаблона Chrome — из
  [каталога сообщества Noctalia](https://github.com/noctalia-dev/community-templates)
* обои — [D3Ext/aesthetic-wallpapers](https://github.com/D3Ext/aesthetic-wallpapers)

## Лицензия

[MIT](LICENSE)
