<div align="center">

# arch-niri-setup

**Scrollable tiling on Arch: niri + Noctalia Shell, with the whole system recoloured from the wallpaper.**

[![Arch Linux](https://img.shields.io/badge/Arch_Linux-1793D1?style=for-the-badge&logo=arch-linux&logoColor=white)](https://archlinux.org)
[![Wayland](https://img.shields.io/badge/Wayland-FFBC00?style=for-the-badge&logo=wayland&logoColor=black)](https://wayland.freedesktop.org)
[![niri](https://img.shields.io/badge/niri-26.04-7FC8FF?style=for-the-badge)](https://github.com/YaLTeR/niri)
[![Noctalia](https://img.shields.io/badge/Noctalia-5.0-8B7CF6?style=for-the-badge)](https://noctalia.dev)
[![kitty](https://img.shields.io/badge/kitty-0.48-52C7B8?style=for-the-badge)](https://sw.kovidgoyal.net/kitty/)
[![License](https://img.shields.io/badge/license-MIT-4CAF50?style=for-the-badge)](LICENSE)

[Русский](README.md) · **English**

</div>

---

## What this is

A desktop setup built on **niri** — a scrollable-tiling Wayland compositor — and
**Noctalia Shell**, which draws the bar, dock, launcher, notifications, wallpaper
and lock screen.

The point: **the colour palette is generated from the current wallpaper** and
propagated across the system — the shell itself, niri's window borders, the
terminal, GTK, Qt/KDE, btop, Telegram and Chrome. Change the wallpaper and
everything follows.

It installs **alongside** your existing desktop rather than replacing it: niri
shows up as a separate entry on the login screen, and Plasma/GNOME stay untouched.

## Stack

| Role | What |
|---|---|
| Compositor | [niri](https://github.com/YaLTeR/niri) — scrollable tiling |
| Shell | [Noctalia](https://noctalia.dev) 5 — bar, dock, launcher, notifications, lock screen, polkit agent |
| Terminal | [kitty](https://sw.kovidgoyal.net/kitty/) |
| Launcher | built into Noctalia, an icon grid like macOS Launchpad |
| GTK theme | `adw-gtk3-dark` plus a generated `noctalia.css` |
| Qt/KDE theme | `kdeglobals` from the `kcolorscheme` template |
| X11 apps | `xwayland-satellite` (niri starts it on demand) |
| Portal | `xdg-desktop-portal-gnome` — screenshots and screen sharing |

## Install

```bash
git clone https://github.com/Marker284/arch-niri-setup.git ~/arch-niri-setup
cd ~/arch-niri-setup
./install.sh
```

| Flag | Effect |
|---|---|
| *(none)* | installs packages and links configs |
| `--no-packages` | configs only |
| `--wallpapers` | also downloads a wallpaper set |
| `--dry-run` | prints what would happen, changes nothing |

Configs are wired up as **symlinks** into this repository, so editing
`~/.config/niri/config.kdl` edits the repo file and it shows up straight away in
`git status`. Anything already in place is moved to
`~/.config/_backup-arch-niri-setup-*` first.

When it finishes, log out and pick the **Niri** session.

## Layout

```
config/
├── niri/config.kdl              compositor: keys, windows, input, blur
├── noctalia/
│   ├── config.toml              bar, dock, launcher, theme, wallpaper
│   └── templates/               custom templates: Telegram and Chrome
├── kitty/kitty.conf             terminal
├── fastfetch/                   config.jsonc plus module scripts
├── qt6ct/qt6ct.conf.in          template — holds an absolute path, so not symlinked
└── autostart/nm-applet.desktop  suppresses nm-applet in niri, avoiding a second Wi-Fi icon
docs/cheatsheet.ru.md            detailed cheat sheet (Russian)
install.sh
```

Generated files stay out of the repo: `noctalia.kdl`, `themes/noctalia.conf`,
`noctalia.css`, `kdeglobals`, `qt6ct/colors/` — Noctalia rebuilds all of them.

## Keys

`Mod` = `Super`. The full list is available in the session itself: `Super+Shift+/`.

| | |
|---|---|
| `Super+Space` | **Launchpad** — app grid and search |
| `Super+Enter` | terminal |
| `Super+E` / `Super+B` | files / browser |
| `Super+Q` | close window |
| `Super+O` | workspace overview (start typing to search) |
| `Super+←/→` or `H/L` | column left / right |
| `Super+↑/↓` or `K/J` | window up / down within a column |
| `Super+R` | cycle column width presets |
| `Super+F` / `Super+Shift+F` | maximize column / fullscreen |
| `Super+1…9` | switch workspace |
| `Super+S` / `Super+V` / `Super+W` | control centre / clipboard / wallpaper |
| `Super+,` | Noctalia settings |
| `Super+Alt+L` | lock the screen |
| `Print` | region screenshot |

Keyboard layout toggles with **Caps Lock**.

## How the wallpaper theming works

Change the wallpaper (`Super+W`) → Noctalia extracts a palette from the image and
runs it through templates:

| Target | Behaviour |
|---|---|
| shell | bar, dock, launcher, notifications — immediately |
| niri | active window border colour (`noctalia.kdl`) — immediately |
| kitty | 16 ANSI colours and background; running windows reload on `SIGUSR1` |
| GTK 3/4 | `~/.config/gtk-*/noctalia.css` — applies on next app start |
| Qt / KDE | `kdeglobals` via the `kcolorscheme` template |
| btop | theme file |
| Telegram | `.tdesktop-theme` — picked up when Telegram starts |
| Chrome | theme extension — via the Update button, or on browser restart |
| Obsidian | CSS snippet in the vault, layered over your theme — live |
| Vesktop / Discord | Vencord theme — applies on next client start |
| Claude Code | `~/.claude/themes/noctalia.json`, pick it via `/theme` — live |
| PrismLauncher | Matugen theme, select it in the launcher settings |

Qt and KDE apps need no template of their own — they read `kdeglobals`, written
by `kcolorscheme`. Dolphin, Ark, Kate, Gwenview, Konsole, qBittorrent, Calibre
and VLC are already in palette.

The generator is set by `[theme] wallpaper_scheme`, here `vibrant`. Of the five
schemes available, it is the only one that keeps the terminal's ANSI colours
clearly distinct; the others collapse them into a single hue.

## One-time hookups

Two applications cannot be recoloured fully automatically — neither exposes an API
for it. Set them up once and they keep working.

**Chrome.** `chrome://extensions` → Developer mode → *Load unpacked* →
`~/.local/share/noctalia/google-chrome-theme`.
The folder is rewritten on every palette change; new colours apply on browser
restart, or right away via the *Update* button on the extension card. That button
cannot be automated: extension reloaders work through `chrome.management`, which
does not re-read `manifest.json` — and the entire theme lives in that file.

**Telegram.** Settings → Appearance → *Chat background* → *Choose from file* →
`~/.config/telegram-desktop/themes/noctalia.tdesktop-theme`.
A theme loaded this way is remembered **by file path** and re-read on every
Telegram start, so colours follow from then on. Applying it live is impossible:
Telegram treats a file passed on the command line as "send to a chat".

## Adding your own apps

The Noctalia community catalogue carries 60+ ready templates — Discord, Spotify,
VS Code, Steam, Obsidian, neovim, rofi, yazi, zen-browser and more:

```toml
[theme.templates]
enable_community_templates = true
community_ids              = ["obsidian", "discord", "claude-code", "prismlauncher"]
```

The community catalogue is already enabled — just append ids. A template is
fetched into a cache first, so the very first apply may be a no-op with
`community template '…' is not cached yet` in the log. Just run
`noctalia msg templates-apply` once more.

Browse them with:
`curl -s https://api.noctalia.dev/templates | python3 -m json.tool | grep name`

## Credits

* [YaLTeR/niri](https://github.com/YaLTeR/niri)
* [noctalia-dev/noctalia-shell](https://github.com/noctalia-dev/noctalia-shell)
* the Telegram template and the base of the Chrome template come from the
  [Noctalia community catalogue](https://github.com/noctalia-dev/community-templates)
* wallpapers — [D3Ext/aesthetic-wallpapers](https://github.com/D3Ext/aesthetic-wallpapers)

## License

[MIT](LICENSE)
