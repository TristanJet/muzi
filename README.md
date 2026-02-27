# muzi

**A snappy, slick terminal client for MPD written in Zig with vim-keybindings and fuzzy-finding.**

![demo-muzi-black](https://github.com/user-attachments/assets/4da905c5-f47c-4530-bceb-649d311f61b0)

## Features
 - Queue manipulation
 - Fuzzy find through entire song library
 - Music browser for manual browsing

## Installation and Usage
muzi works on linux and macos

muzi is available on the [AUR](https://aur.archlinux.org/packages/muzi)

```bash
yay -S muzi
```

To build muzi from source you need [Zig 0.15.2](https://ziglang.org/download/) and the zig standard library installed, running the following command in the source directory will build to ${SRC-DIR}/zig-out/bin/

```bash
zig build -Drelease=true
```

A running [mpd](https://github.com/MusicPlayerDaemon/MPD) instance will be required. The default host and port are 127.0.0.1:6600. The port and host can be specified as so:

```bash
muzi -H "127.0.0.1" -p 6600
```
muzi is a *stateful* mpd client so if the mpd library is updated while muzi is active it will need to be resynced. This must be done by quitting and launching the program again.

## Keybinds

**normal queue**

All *delete* commands save the selected songs to a yank buffer
| key   | action    |
|---    |---        |
| q     | quit      |
| f     | switch to fuzzy find                       |
| b     | switch to browser      |
| k     | cursor up        |
| j     | cursor down      |
| Ctrl+U     | cursor up half queue      |
| Ctrl+D     | cursor down half queue      |
| g     | go top      |
| G     | go bottom      |
| ENTER     | play selected song      |
| SPACE | play/pause        |
| h     | prev song      |
| l     | next song      |
| r     | toggle *repeat* state      |
| z     | toggle *random* state      |
| s     | toggle *single* state      |
| c     | toggle *consume* state      |
| left     | seek -5      |
| right     | seek +5      |
| SHIFT+left     | seek -15      |
| SHIFT+right     | seek +15      |
| up     | increase volume +5      |
| down     | decrease volume -5            |
| SHIFT+up     | increase volume +15      |
| SHIFT+down     | decrease volume -15            |
| x, d     | delete from queue at cursor position              |
| X     | clear queue      |
| D     | clear till      |
| y     | yank at current position  |
| Y     | yank till end         |
| p     | put (in yank buffer)      |
| v     | enter visual mode         |

**visual queue**

*delete* and *yank* commands save the selected songs to a yank buffer and exit to *normal queue* input mode

| key   | action    |
|---    |---|
| ESC, v   | exit visual mode |
| k     | cursor up        |
| j     | cursor down      |
| Ctrl+U     | cursor up half queue      |
| Ctrl+D     | cursor down half queue                                 |
| g     | go top      |
| G     | go bottom      |
| d, x  | delete selected |
| y     | yank selected |

**fuzzy find**
| key   | action    |
|---    |---        |
| ESC     | return to normal queue          |
| Backspace | delete typed                                                  |
| Ctrl+U     | cursor up      |     
| Ctrl+D     | cursor down      |
| ENTER     | add song to queue      |
| *rest*     |  type      |

**browser**
| key   | action    |
|---    |---        |
| ESC     | return to normal queue      |
| k     | cursor up        |
| j     | cursor down      |
| Ctrl+U     | cursor up half queue      |
| Ctrl+D     | cursor down half queue             |
| g     | go top      |
| G     | go bottom                     |
| h     | prev column      |
| l     | next column      |
| n     | cycle *forward* 10 best query matches      |
| N     | cycle *backward* 10 best query matches      |
| ENTER     | add to queue      |
| SPACE     | clear queue + add to queue |
| /     | search in column      |
| ENTER, ESC *while searching    | exit search |
| Backspace *while searching    | delete typed |
