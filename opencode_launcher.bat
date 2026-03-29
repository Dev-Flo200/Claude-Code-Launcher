@echo off
chcp 65001 >nul
powershell -NoProfile -ExecutionPolicy Bypass -Command "& '%~dp0opencode_launcher.ps1'"
pause
