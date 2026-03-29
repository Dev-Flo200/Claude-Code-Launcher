# OpenCode 启动器 Configuration
$PresetDirs = @(
    'E:\Project_ALL\ClaudeWork2222',
    'E:\Project_ALL\ClaudeWork',
    'E:\Documents\notes'
)

$OpenCodeCmd = 'opencode'

$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8

function Show-Menu {
    param(
        [string[]]$Options,
        [int]$SelectedIndex,
        [int]$StartY
    )
    
    for ($i = 0; $i -lt $Options.Count; $i++) {
        [Console]::SetCursorPosition(0, $StartY + $i)
        Write-Host (' ' * 70) -NoNewline
        [Console]::SetCursorPosition(0, $StartY + $i)
        $prefix = if ($i -eq $SelectedIndex) { '> ' } else { '  ' }
        $color = if ($i -eq $SelectedIndex) { 'Cyan' } else { 'White' }
        Write-Host "$prefix$($Options[$i])" -ForegroundColor $color
    }
    
    [Console]::SetCursorPosition(0, $StartY + $Options.Count + 2)
    Write-Host (' ' * 70) -NoNewline
    [Console]::SetCursorPosition(0, $StartY + $Options.Count + 2)
    Write-Host '请使用上下箭头移动，回车确认' -ForegroundColor Gray
}

function Invoke-MenuSelection {
    param([string[]]$Options, [int]$StartY)
    
    $selected = 0
    $max = $Options.Count - 1
    
    Show-Menu -Options $Options -SelectedIndex $selected -StartY $StartY
    
    while ($true) {
        $key = [Console]::ReadKey($true)
        
        if ($key.Key -eq 'UpArrow') {
            if ($selected -gt 0) {
                $selected--
                Show-Menu -Options $Options -SelectedIndex $selected -StartY $StartY
            }
        }
        elseif ($key.Key -eq 'DownArrow') {
            if ($selected -lt $max) {
                $selected++
                Show-Menu -Options $Options -SelectedIndex $selected -StartY $StartY
            }
        }
        elseif ($key.Key -eq 'Enter') {
            return $selected
        }
    }
}

function Main {
    $allDirs = @('当前目录') + $PresetDirs
    
    while ($true) {
        Clear-Host
        Write-Host '========================================' -ForegroundColor Cyan
        Write-Host '       OpenCode 启动器' -ForegroundColor Cyan
        Write-Host '========================================' -ForegroundColor Cyan
        Write-Host '工作目录：' -ForegroundColor Yellow
        Write-Host ''
        Write-Host '[1/2] 请选择工作目录' -ForegroundColor Green
        Write-Host ''
        
        $menuStartY = [Console]::CursorTop
        $selected = Invoke-MenuSelection -Options $allDirs -StartY $menuStartY
        
        if ($selected -eq 0) {
            $workDir = $PWD.Path
        } else {
            $workDir = $PresetDirs[$selected - 1]
        }
        
        if (-not (Test-Path $workDir)) {
            Clear-Host
            Write-Host '========================================' -ForegroundColor Cyan
            Write-Host '       OpenCode 启动器' -ForegroundColor Cyan
            Write-Host '========================================' -ForegroundColor Cyan
            Write-Host "工作目录： $workDir" -ForegroundColor Yellow
            Write-Host ''
            Write-Host '[1/2] 请选择工作目录' -ForegroundColor Green
            Write-Host ''
            Write-Host '错误： 目录不存在' -ForegroundColor Red
            Write-Host ''
            Write-Host '按任意键继续...' -ForegroundColor Gray
            [Console]::ReadKey($true) | Out-Null
            continue
        }
        
        break
    }
    
    $sessionOptions = @('新建会话', '继续上次会话')
    
    while ($true) {
        Clear-Host
        Write-Host '========================================' -ForegroundColor Cyan
        Write-Host '       OpenCode 启动器' -ForegroundColor Cyan
        Write-Host '========================================' -ForegroundColor Cyan
        Write-Host "工作目录： $workDir" -ForegroundColor Yellow
        Write-Host ''
        Write-Host '[2/2] 是否继续上次会话？' -ForegroundColor Green
        Write-Host ''
        
        $menuStartY = [Console]::CursorTop
        $sessionSelected = Invoke-MenuSelection -Options $sessionOptions -StartY $menuStartY
        
        if ($sessionSelected -eq 0) {
            $openCodeArgs = ''
            $sessionDesc = '新建会话'
        } else {
            $openCodeArgs = '-c'
            $sessionDesc = '继续上次会话'
        }
        
        break
    }
    
    Clear-Host
    Write-Host '========================================' -ForegroundColor Cyan
    Write-Host '       OpenCode 启动器' -ForegroundColor Cyan
    Write-Host '========================================' -ForegroundColor Cyan
    Write-Host "工作目录： $workDir" -ForegroundColor Yellow
    Write-Host ''
    Write-Host '[2/2] 是否继续上次会话？' -ForegroundColor Green
    Write-Host ''
    Write-Host "  $sessionDesc" -ForegroundColor Cyan
    Write-Host ''
    Write-Host '正在启动...' -ForegroundColor Yellow
    
    Push-Location $workDir
    
    try {
        if ($openCodeArgs) {
            & $OpenCodeCmd -c
        } else {
            & $OpenCodeCmd
        }
    } catch {
        Write-Host ''
        Write-Host '[错误] 未找到OpenCode命令' -ForegroundColor Red
        Write-Host '请确保OpenCode已安装并在PATH中' -ForegroundColor Red
        Write-Host ''
        Write-Host '按任意键退出...' -ForegroundColor Gray
        [Console]::ReadKey($true) | Out-Null
    }
    
    Pop-Location
}

Main
