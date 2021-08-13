# SyncTERM Installer for Windows

This repository is only for building a windows installer for SyncTERM, and does
not contain [SyncTERM source code](https://gitlab.synchro.net/main/sbbs/-/commits/master/src/syncterm).

Downloads:

- [Stable Release](https://github.com/bbs-io/syncterm-windows/releases/tag/stable)
- [Development Release](https://github.com/bbs-io/syncterm-windows/releases/tag/dev)

The latest builds will have a recent shared Synchronet BBS List included.

## About Syncterm

[SyncTERM](http://syncterm.net/) is a BBS terminal program which supports:
- Windows, Linux, OpenBSD, NetBSD, OS X, and FreeBSD
- X/Y/ZModem up/downloads
- Runs in full-screen mode on ALL platforms (ALT-Enter switches modes)
- *nix versions will run using SDL, X11, or using curses
- Full ANSI-BBS support
- Full CGTerm Commodore 64 PETSCII support
- Full Atari 8-bit ATASCII support
- DoorWay support
- Support for IBM low and high ASCII including the face graphics (☺ and ☻) and card symbols (♥, ♦, ♣, and ♠) which so many other terms have problems with (may not work in curses mode... depends on the terminal being used).
- Phone books
- Multiple screen modes (80x25, 80x28, 80x43, 80x50, 80x60, 132x25, 132x28, 132x30, 132x34, 132x43, 132x50, 132x60)
- ANSI Music (through the sound card if installed)
- Telnet, RLogin, SSH, RAW, modem, shell (*nix only) and direct serial connections
- Auto-login with Synchronet RLogin
- Large Scrollback
- Mouse-driven menus
- Copy/Paste
- Supports character pacing for ANSI animation as well as the VT500 `ESC[*r` sequence to allow dynamic speed changes
- Comes with 43 standard fonts and allows the BBS to change the current font *and* upload custom fonts. [This tool](http://syncterm.net/FED.ZIP) will allow you to create fonts for use with SyncTERM.
- Supports Operation Overkill ][ Terminal emulation

For detailed specs on SyncTERMs handling of ANSI, as well as it's many extensions, refer to [this document](https://gitlab.synchro.net/main/sbbs/-/raw/master/src/conio/cterm.txt)

Please file bug reports at the SourceForge [bug tracker](https://sourceforge.net/p/syncterm/tickets/) and feature requests in the [Feature Request tracker](https://sourceforge.net/p/syncterm/feature-requests/).

## Building

This repository builds the latest stable or dev SyncTERM Installer for Windows.

```
npm ci
npm run build
```

For the latest dev build: `SET BUILD_TYPE=dev` before running build command.

## Reference Files

- Latest - https://sourceforge.net/projects/syncterm/files/latest/download
- Development - https://syncterm.bbsdev.net/syncterm.zip


<!-- Comment to keep CI/CD daily events going, needs updating regularly: 2021-08-13 -->
