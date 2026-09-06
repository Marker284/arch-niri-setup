# niri + Noctalia Shell — шпаргалка

Установлено рядом с Plasma: на экране входа (Plasma Login) внизу выбираешь
сессию — **Plasma** или **Niri**. Плазма работает как работала; общий у сессий
только `kdeglobals` — цвета KDE-программ теперь берутся из обоев (см. ниже).

---

## Что где лежит

| Файл | Что это |
|---|---|
| `~/.config/niri/config.kdl` | композитор: клавиши, окна, тачпад, монитор |
| `~/.config/niri/noctalia.kdl` | **генерируется** — цвета рамок из обоев, не править |
| `~/.config/noctalia/config.toml` | оболочка: бар, док, лаунчер, тема, обои |
| `~/.local/state/noctalia/settings.toml` | то, что накликано мышкой в Настройках (перекрывает config.toml) |
| `~/.config/kitty/kitty.conf` | терминал |
| `~/.config/kdeglobals` | **генерируется** — цвета KDE/Qt-программ (общий с Plasma) |
| `~/.config/qt6ct/` | палитра для Qt-программ вне KDE |
| `~/.config/noctalia/templates/` | свои шаблоны: Telegram, Chrome |
| `~/.local/share/noctalia/google-chrome-theme/` | **генерируется** — тема-расширение для Chrome |
| `~/Pictures/Wallpapers/` | обои (13 шт.) |
| `~/.config/_backup-before-niri-*/` | бэкап твоих старых gtk.css |

Оба конфига перечитываются на лету — сохранил файл, изменения сразу видны.
Проверить синтаксис: `niri validate` и `noctalia config validate`.

---

## Горячие клавиши

**Mod = Super (клавиша Win).** Полный список в системе: `Super+Shift+/`

### Запуск и панели
| Клавиши | Действие |
|---|---|
| `Super+Space` | **Launchpad** — сетка приложений и поиск |
| `Super+D` | то же самое |
| `Super+Enter` | терминал (kitty) |
| `Super+E` | файлы (Dolphin) |
| `Super+B` | браузер (Chrome) |
| `Super+S` | центр управления (wifi, звук, bluetooth) |
| `Super+V` | история буфера обмена |
| `Super+W` | выбрать обои |
| `Super+Shift+W` | случайные обои |
| `Super+Shift+D` | тёмная ⇄ светлая тема |
| `Super+,` | настройки Noctalia (всё мышкой) |
| `Alt+Tab` | переключатель окон |

Внутри Launchpad работают префиксы: `/calc 2+2`, `/emo кот`, `/wall`, `/win`.
Просто `2+2` тоже считает.

### Окна (niri — «скроллящийся» тайлинг)
| Клавиши | Действие |
|---|---|
| `Super+Q` | закрыть окно |
| `Super+O` | обзор всех рабочих столов (можно сразу печатать — начнётся поиск) |
| `Super+←/→` или `Super+H/L` | перейти к колонке слева/справа |
| `Super+↑/↓` или `Super+K/J` | перейти к окну выше/ниже в колонке |
| `Super+Ctrl+стрелки` | передвинуть окно |
| `Super+R` | циклом менять ширину колонки (1/3 → 1/2 → 2/3) |
| `Super+F` | развернуть колонку |
| `Super+Shift+F` | полный экран |
| `Super+M` | развернуть до краёв экрана |
| `Super+C` | отцентрировать колонку |
| `Super+-` / `Super+=` | ширина ±10% |
| `Super+Shift+Space` | окно в «плавающий» режим и обратно |
| `Super+T` | колонка во вкладках |
| `Super+[` / `Super+]` | втянуть/вытолкнуть соседнее окно в колонку |
| `Super+.` | вытолкнуть окно из колонки |

### Рабочие столы
| Клавиши | Действие |
|---|---|
| `Super+1…9` | перейти на стол |
| `Super+Ctrl+1…9` | перенести окно на стол |
| `Super+PgUp/PgDn` или `Super+I/U` | стол выше/ниже |
| `Super+колесо` | листать столы |

### Скриншоты и сессия
| Клавиши | Действие |
|---|---|
| `Print` | выделить область (встроенное в niri) |
| `Ctrl+Print` | весь экран |
| `Alt+Print` | активное окно |
| `Super+Shift+S` | область через Noctalia |
| `Super+Alt+L` | заблокировать экран |
| `Super+Shift+X` | меню выключения |
| `Super+Shift+E` | выйти из niri |

Раскладка переключается **Caps Lock** — как в Plasma.

---

## Как работает «тема под обои»

Меняешь обои (`Super+W`) → Noctalia вытаскивает палитру из картинки и
перерисовывает по шаблонам:

- **сама оболочка** — бар, док, лаунчер, уведомления;
- **niri** — цвет рамки активного окна (`noctalia.kdl`);
- **kitty** — все 16 ANSI-цветов + фон (живые окна перекрашиваются сразу);
- **GTK 3/4** — через `~/.config/gtk-*/noctalia.css` (база — `adw-gtk3-dark`);
- **Qt / KDE** (Dolphin, Ark, Kate, Gwenview) — через `~/.config/kdeglobals`,
  шаблон `kcolorscheme`;
- **прочие Qt** — через `~/.config/qt6ct/colors/noctalia.conf`;
- **btop**;
- **Telegram** и **Google Chrome** — свои шаблоны, см. ниже.

Настроено в `~/.config/noctalia/config.toml`:

```toml
[theme]
source           = "wallpaper"   # палитра из обоев
wallpaper_scheme = "vibrant"     # схема генерации
mode             = "dark"        # dark | light | auto (по восходу/закату)

[theme.templates]
builtin_ids = ["niri", "kitty", "gtk3", "gtk4", "qt", "kcolorscheme", "btop"]
```

### Чем красятся GTK и Qt

В `~/.config/niri/config.kdl`, блок `environment`:

```
GTK_THEME            "adw-gtk3-dark"   # база для GTK
QT_QPA_PLATFORMTHEME "kde"             # Qt берёт цвета из kdeglobals
```

`kde` — единственный вариант, при котором KDE-программы выглядят правильно:
они читают цвета через KColorScheme из `kdeglobals`, а не из палитры Qt.
С `qt6ct` выходило наполовину — подложка светлая от Breeze, текст светлый от
Qt-палитры, то самое «белое на белом».

Другие схемы, если захочешь другой характер цветов:
`m3-tonal-spot` (мягкая, «материальная»), `m3-content` (ближе к оригиналу),
`m3-fruit-salad`, `m3-rainbow`, `m3-monochrome`, `faithful`, `muted`.

Все доступные шаблоны: `noctalia theme --list-templates`
(есть ещё alacritty, foot, ghostty, wezterm, helix, emacs, cava, starship —
добавляй id в `builtin_ids`).

---

## Telegram и Chrome

Оба собираются своими шаблонами из `~/.config/noctalia/templates/`
(`telegram.tdesktop-theme`, `chrome-manifest.json` + скрипты применения).
Файлы пересобираются автоматически при каждой смене обоев.

### Google Chrome — полностью автоматически, но подключить один раз

Тема Chrome — это распакованное расширение. Noctalia перезаписывает всегда одну
и ту же папку, поэтому подключение разовое:

1. `chrome://extensions`
2. включить **Режим разработчика**
3. **Загрузить распакованное расширение** → выбрать
   `~/.local/share/noctalia/google-chrome-theme`

Дальше при смене обоев папка обновляется сама.

**Про «на горячую».** Полностью автоматически, без единого действия, цвета
Chrome не обновит: он перечитывает распакованное расширение с диска только при
старте браузера либо по кнопке **«Обновить»** (⟳) на карточке расширения в
`chrome://extensions`. Кнопка — это единственный способ без перезапуска, зато
мгновенный и вкладки не теряются.

Автоматизировать эту кнопку нельзя: расширения-перезагрузчики работают через
`chrome.management` (выключить/включить), а он, по документации Chrome,
**не перечитывает `manifest.json`** — а вся наша тема как раз в нём. Ключ
`--load-extension` в Chrome 137+ тоже отключён, и `chrome://restart` из
командной строки не срабатывает. Так что: либо кнопка «Обновить», либо
следующий запуск Chrome.

Дополнительно, когда Chrome **закрыт**, скрипт кладёт в его `Preferences`
seed-цвет (`browser.theme.user_color`) — из него Chrome красит те места, куда
тема-расширение не дотягивается. При запущенном Chrome файл не трогается: он
всё равно перезапишет его при выходе.

### Telegram — подключить один раз, дальше автоматически

Палитра `~/.config/telegram-desktop/themes/noctalia.tdesktop-theme`
пересобирается при каждой смене обоев.

Подключается она **один раз**:

**Настройки → Оформление → блок «Фон чата» → «Выбрать из файла»** → указать
этот файл.

Важное свойство: подключённую так тему Telegram запоминает **по пути к файлу** и
перечитывает при каждом своём запуске (это описано в
[официальной вики tdesktop](https://github.com/telegramdesktop/tdesktop/wiki/Theme-Reference)).
Путь у нас постоянный, поэтому после разовой настройки новые цвета встают сами —
при следующем старте Telegram.

Применить прямо на лету нельзя: у Telegram Desktop нет ни ключа командной
строки, ни IPC для смены темы — файл в аргументах он понимает как «отправить в
чат». Поэтому единственное, что делает хук, — присылает уведомление, и только
когда палитра действительно изменилась. Не нужно и оно — добавь в блок
`environment` в `~/.config/niri/config.kdl`:

```
NOCTALIA_TELEGRAM_NOTIFY "0"
```

### Добавить ещё программы

В каталоге сообщества 60+ готовых шаблонов (Discord, Spotify, VS Code, Steam,
Obsidian, neovim, rofi, yazi, fastfetch, zen-browser…). Включить:

```toml
[theme.templates]
enable_community_templates = true
community_ids              = ["discord", "vscode", "spicetify"]
```

Список: `curl -s https://api.noctalia.dev/templates | python3 -m json.tool | grep name`

---

## Полезное

**Автосмена обоев** — в `config.toml`:
```toml
[wallpaper.automation]
enabled          = true
interval_seconds = 1800
```

**Погода** сейчас включена и определяет город по IP. Выключить:
```toml
[location]
auto_locate = false
[weather]
enabled = false
```

**Автоблокировка** — 10 минут до локскрина, 12 до гашения экрана
(`[idle.behavior.*]`).

**Док** снизу спрятан, выезжает при подведении мыши к нижнему краю.
Всегда показывать: `auto_hide = false` в `[dock]`.

**Светлая тема:** `Super+Shift+D`. Заодно поменяй в `~/.config/niri/config.kdl`
строку `GTK_THEME "adw-gtk3-dark"` на `"adw-gtk3"` — это база, поверх которой
кладутся цвета обоев.

**Плазма тоже перекрасилась.** `kdeglobals` один на обе сессии, поэтому
KDE-программы и в Plasma теперь в цветах обоев. Вернуть Plasma прежний вид:
Параметры системы → Оформление → Цвета → `Breeze Dark`. После этого в niri
цвета вернутся при следующей смене обоев или по `noctalia msg templates-apply`.

**Иконки и шрифты GTK** правятся программой `nwg-look` (уже стоит).

**Логи, если что-то не так:**
```
~/.cache/noctalia/noctalia.log
journalctl --user -u niri -b
```

---

## Что стоит доставить по вкусу

```
yay -S ghostty          # альтернативный терминал (шаблон цветов уже есть)
sudo pacman -S cava     # визуализатор звука, тоже красится под обои
sudo pacman -S starship # промпт для fish, шаблон цветов есть
sudo pacman -S swappy satty   # редактор скриншотов
```
