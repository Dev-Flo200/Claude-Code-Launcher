@echo off
chcp 65001 >nul
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0opencode_launcher.ps1"
if %errorlevel% neq 0 pause
