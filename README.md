# SyncTERM Installer For Windows

To build the installer run `build.cmd`

## Prebuild Script (build.js)

Uses Node.js (12.13+) to download/extract and prepare input directory.

* Downloads Nightly [SyncTERM](https://syncterm.bbsdev.net/) for Windows
* Downloads [Synchronet BBS List](http://vert.synchro.net/sbbslist.ssjs)
* Creates `./input/SyncTERM-Setup.iss` from template with version and build date.
* Runs Inno Setup against Installation Creation Script

## Installer Build Script

The setup script in use requires [Inno Setup 6](http://www.jrsoftware.org/isdl.php).
