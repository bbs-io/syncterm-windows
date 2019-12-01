@echo off
cd /d %~dp0

npm i esm node-fetch shelljs promise-ftp
npm -r esm build.js
