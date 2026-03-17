@echo off
setlocal enabledelayedexpansion

:: ====== 常用目录配置 ======
:: 在此添加你的常用项目目录，格式：set "DIR_序号=目录路径"
set "DIR_1=E:\Project_ALL\ClaudeWork"
set "DIR_2=E:\Documents\notes"

:: ==========================

:: 生成唯一临时文件名（使用随机数），避免多实例冲突
set "RANDOM_ID=%RANDOM%"
set "TEMP_MENU=%TEMP%\claude_menu_%RANDOM_ID%.txt"
set "TEMP_RESULT=%TEMP%\claude_result_%RANDOM_ID%.txt"

:: 清理上次的 debug 日志
del "%TEMP%\claude_debug.log" 2>nul
echo [DEBUG BAT] Script started >> "%TEMP%\claude_debug.log"

:: 自动检测目录数量（自动统计已配置的 DIR_* 变量数量）
set MAX_DIR=0
:count_dirs
set /a MAX_DIR+=1
if !MAX_DIR! LSS 100 (
    call set "VAR_NAME=DIR_%%MAX_DIR%%"
    if defined !VAR_NAME! goto count_dirs
)
set /a MAX_DIR-=1

:: ====== 功能1: 选择工作目录 ======
:: 显示目录选择菜单，通过 PowerShell 调用 claude_menu.ps1 实现上下箭头选择
:func1_loop
chcp 65001 >nul
cls
echo ========================================
echo       Claude Code 启动器
echo ========================================
echo 工作目录：
echo.
echo [1/2] 请选择工作目录
echo.

:: 创建选项文件（提示+选项）
(
    echo HINT:请使用上下箭头移动，回车确认
    echo 当前目录
    for /L %%i in (1,1,!MAX_DIR!) do echo !DIR_%%i!
) > "!TEMP_MENU!"

:: 调用 PowerShell 菜单组件，传递临时文件名
del "!TEMP_RESULT!" 2>nul
echo [DEBUG BAT] Calling PowerShell, TEMP_RESULT=!TEMP_RESULT! >> "%TEMP%\claude_debug.log"
powershell -NoProfile -ExecutionPolicy Bypass -Command "& '%~dp0claude_menu.ps1' '!TEMP_MENU!' '!TEMP_RESULT!'"
chcp 65001 >nul

:: 读取返回值并检查
set /p IDX=<"!TEMP_RESULT!"
echo [DEBUG BAT] After read, IDX='!IDX!' >> "%TEMP%\claude_debug.log"
echo [DEBUG BAT] After read, IDX='!IDX!'
if not defined IDX goto func1_loop

:: 处理选择结果
if "%IDX%"=="0" (
    set "WORKDIR=!CD!"
) else (
    call set "WORKDIR=!DIR_%IDX%!"
)

echo [DEBUG BAT] WORKDIR set to: '!WORKDIR!' >> "%TEMP%\claude_debug.log"

:: 检查目录是否存在，不存在则提示重新选择
if exist "!WORKDIR!" goto func1_ok
cls
echo ========================================
echo       Claude Code 启动器
echo ========================================
echo 工作目录：选择目录不存在，请重新选择
echo.
echo [1/2] 请选择工作目录
echo.
pause
goto func1_loop

:func1_ok

:: ====== 功能2: 选择会话模式 ======
:: 选择"继续上次会话"或"新建会话"
:show_func2
cls
echo ========================================
echo       Claude Code 启动器
echo ========================================
echo 工作目录：!WORKDIR!
echo.

echo [2/2] 是否继续上次会话？
echo.
powershell -NoProfile -Command "Write-Host '提示：若该工作目录未在 Claude 中使用过，选择"继续上次会话"会直接退出' -ForegroundColor Yellow"
echo.

:: 创建选项文件（提示+选项）
(
    echo HINT:请使用上下箭头移动，回车确认
    echo 新建会话
    echo 继续上次会话
) > "!TEMP_MENU!"

:: 调用 PowerShell 菜单组件，传递临时文件名
del "!TEMP_RESULT!" 2>nul
echo [DEBUG BAT] Calling PowerShell for func2, TEMP_RESULT=!TEMP_RESULT! >> "%TEMP%\claude_debug.log"
powershell -NoProfile -ExecutionPolicy Bypass -Command "& '%~dp0claude_menu.ps1' '!TEMP_MENU!' '!TEMP_RESULT!'"
chcp 65001 >nul

:: 读取返回值并检查
set /p IDX=<"!TEMP_RESULT!"
echo [DEBUG BAT] func2 After read, IDX='!IDX!' >> "%TEMP%\claude_debug.log"
if not defined IDX goto show_func2

:: 设置启动命令（0=新建，1=继续）
if "%IDX%"=="0" (
    set "CLAUDE_CMD=claude"
    set "SESSION_TYPE=Claude新会话"
) else (
    set "CLAUDE_CMD=claude -c"
    set "SESSION_TYPE=Claude继续上次会话"
)

:: ====== 启动 Claude Code ======
cls
echo ========================================
echo       Claude Code 启动器
echo ========================================
echo 工作目录：!WORKDIR!
echo.

echo [2/2] 是否继续上次会话？
echo.
echo   !SESSION_TYPE!
echo.
echo 正在启动...
cd /d "!WORKDIR!"

:: 检查 Claude 命令是否可用
where claude >nul 2>nul
if errorlevel 1 (
    :: 命令不存在
    echo.
    echo [错误] 未找到 Claude Code 命令
    echo 请确保 Claude Code 已安装并配置到 PATH 环境变量
    echo.
    echo 按任意键退出...
    pause >nul
    exit /b 1
) else (
    :: 命令可用，启动 Claude
    start "" !CLAUDE_CMD!

    :: 清理临时文件
    del "!TEMP_MENU!" 2>nul
    del "!TEMP_RESULT!" 2>nul

    echo.
    echo [成功] Claude Code 已启动，临时文件已清理
    echo.
    :: 等待1秒后自动关闭
    ping -n 2 127.0.0.1 >nul
    exit
)
