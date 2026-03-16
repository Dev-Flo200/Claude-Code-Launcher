# Claude Code 启动器

通过交互式菜单快速启动 Claude Code。

## 文件说明

| 文件 | 说明 |
|------|------|
| `claude_launcher.bat` | 主程序，双击运行 |
| `claude_menu.ps1` | 菜单组件，供 bat 调用 |

## 使用方法

1. **配置目录**：编辑 `claude_launcher.bat`，在 `DIR_1`、`DIR_2` 处填入你的项目路径

```bat
:: 最多支持 99 个目录
set "DIR_1=E:\Project\MyApp"
set "DIR_2=E:\Project\AnotherApp"
set "DIR_3=E:\Project\Demo"
```

2. **运行**：双击 `claude_launcher.bat`

3. **操作**：
   - 使用 **上下箭头** 选择
   - 按 **回车** 确认
   - 先选工作目录，再选会话模式

4. **会话模式**：
   - 继续上次会话：用 `claude -c` 恢复之前的对话
   - 新建会话：用 `claude` 全新开始

## 效果预览

```
========================================
       Claude Code 启动器
========================================
工作目录：

[1/2] 请选择工作目录

> 当前目录
  E:\Project\MyApp
  E:\Project\AnotherApp

请使用上下箭头移动，回车确认
```

## 临时文件

脚本运行时会生成以下临时文件（位于系统 Temp 目录）：

| 文件 | 作用 |
|------|------|
| `claude_menu_随机数.txt` | 存储菜单选项和提示文本，由 bat 生成供 ps1 读取 |
| `claude_result_随机数.txt` | 存储用户选择的索引，由 ps1 生成供 bat 读取 |

**示例**（随机数 12345）：
- `%TEMP%\claude_menu_12345.txt`
- `%TEMP%\claude_result_12345.txt`

**多实例支持**：
- 每次运行使用随机数生成唯一文件名
- 支持同时运行多个脚本实例，互不干扰

**清理**：
- 脚本运行结束后自动清理临时文件
- 启动成功：显示"Claude Code 已启动，临时文件已清理"，1秒后自动关闭
- 启动失败：显示错误信息，按任意键退出
