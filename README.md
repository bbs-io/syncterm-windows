# SyncTERM Installer For Windows

To build the installer run `build.cmd`

## Prebuild Script (build.js)

Uses Node.js to download/extract and prepare input directory.

* Download Nightly [SyncTERM](https://syncterm.bbsdev.net/) for Windows
* Download [Synchronet BBS List](http://vert.synchro.net/sbbslist.ssjs)
* Create `./input/SyncTERM-Setup.iss` from template with version and build date.
* Run Inno Setup against Installation Creation Script

## Installer Build Script

The setup script in use requires Inno Setup, and the precompiler directive 
support.


Inno Setup home page
    http://www.jrsoftware.org/isinfo.php

    
    
Inno Setup download page
    http://www.jrsoftware.org/isdl.php
    
    
    
Inno Setup Install:
    http://www.jrsoftware.org/download.php/is.exe?site=1
    
    
    
Inno Setup QuickStart Pack:
	Install this after InnoSetup is installed, I suggest installing all
	the packages available.
	
	http://files.jrsoftware.org/ispack/ispack-5.1.8.exe
