@echo off
cd /d %~dp0

CALL npm ci
CALL npm run build
