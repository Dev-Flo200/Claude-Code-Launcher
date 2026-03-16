param(
    [string]$MenuFile,
    [string]$ResultFile
)
# ============================================================
# PowerShell 菜单组件 (claude_menu.ps1)
# 功能：读取选项文件，生成上下箭头选择的交互式菜单
# 参数：
#   - MenuFile: 菜单选项文件路径（由 bat 生成）
#   - ResultFile: 结果输出文件路径（供 bat 读取）
# 输入文件格式：第一行 HINT:提示文本，之后每行一个选项
# ============================================================

# 强制 UTF-8 输出（解决中文显示问题）
chcp 65001 > $null
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8

# 读取文件内容并解析
$Lines = Get-Content -Path $MenuFile -Encoding UTF8

# 解析 HINT 行和选项列表
$HintText = ""  # 底部提示文字
$Dirs = @()     # 菜单选项数组
foreach ($Line in $Lines) {
    if ($Line -match "^HINT:(.*)$") {
        $HintText = $matches[1]
    } else {
        $Dirs += $Line
    }
}

# 初始化选中状态
$selected = 0          # 当前选中项索引
$max = $Dirs.Count - 1 # 最后一项索引
$startY = [Console]::CursorTop  # 菜单起始行

# 移动选择指示器：清除旧位置显示，新位置显示 > 前缀
function Move-Selection {
    param($old, $new, $startY, $dirs)
    [Console]::SetCursorPosition(0, $startY + $old)
    Write-Host (" " * 100)
    [Console]::SetCursorPosition(2, $startY + $old)
    Write-Host $dirs[$old]
    [Console]::SetCursorPosition(0, $startY + $new)
    Write-Host (" " * 100)
    [Console]::SetCursorPosition(0, $startY + $new)
    Write-Host ("> " + $dirs[$new]) -ForegroundColor Cyan
}

# 绘制菜单：显示所有选项，底部显示提示文字
function Draw-Menu {
    param($dirs, $startY, $hint)
    for ($i = 0; $i -lt $dirs.Count; $i++) {
        [Console]::SetCursorPosition(0, $startY + $i)
        Write-Host (" " * 100)
        [Console]::SetCursorPosition(2, $startY + $i)
        Write-Host $dirs[$i]
    }
    [Console]::SetCursorPosition(0, $startY + $dirs.Count + 1)
    Write-Host $hint -NoNewline -ForegroundColor Gray
}

[Console]::CursorVisible = $false
Draw-Menu -dirs $Dirs -startY $startY -hint $HintText

# 初始选中第一项（显示 > 标记）
[Console]::SetCursorPosition(0, $startY)
Write-Host ("> " + $Dirs[0]) -ForegroundColor Cyan

# 键盘事件循环：上下箭头选择，回车确认
while ($true) {
    $key = [Console]::ReadKey($true)
    if ($key.Key -eq "UpArrow") {
        if ($selected -gt 0) {
            $old = $selected
            $selected--
            Move-Selection -old $old -new $selected -startY $startY -dirs $Dirs
        }
    } elseif ($key.Key -eq "DownArrow") {
        if ($selected -lt $max) {
            $old = $selected
            $selected++
            Move-Selection -old $old -new $selected -startY $startY -dirs $Dirs
        }
    } elseif ($key.Key -eq "Enter") {
        [Console]::SetCursorPosition(0, $startY + $Dirs.Count + 1)
        Write-Host (" " * 100)
        break
    }
}

[Console]::CursorVisible = $true

# 写入返回值文件（供 bat 脚本读取选中索引）
$selected | Out-File -FilePath $ResultFile -Encoding UTF8

exit $selected
