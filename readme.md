# 📁 Files Tree Tools

一个用于生成目录文件列表的 Windows 工具集，支持输出树状结构、Markdown 和 HTML 格式，并提供临时网络服务功能。

## ✨ 功能特性

- 🌳 **树状结构** - 生成完整的目录树形结构（FileList.txt）
- 📝 **Markdown 格式** - 生成带链接的 Markdown 文件列表（FileList.md）
- 🌐 **HTML 网页** - 生成美观的 HTML 文件列表页面（FileList.html）
- 🔗 **文件链接** - `.md` 及 `.html` 文件均带有可点击的打开/下载链接
- 🚫 **排除配置** - 支持自定义排除文件和文件夹
- 📡 **网络服务** - 可选启动临时 HTTP 服务器，支持局域网访问
- 🎨 **美化样式** - HTML 页面带有现代化 UI 设计和交互效果

## 📂 文件说明

| 文件名 | 类型 | 功能描述 |
|--------|------|----------|
| [FilesName-html+web.bat](FilesName-html+web.bat) | 批处理 | **推荐** - 生成 HTML+MD+TXT 并可选启动网络服务 |
| [FilesName-html+web.ps1](FilesName-html+web.ps1) | PowerShell | 同上，使用 PowerShell 实现，Argon UI 样式 |
| [FilesName-html.bat](FilesName-html.bat) | 批处理 | 生成 HTML+MD+TXT 文件列表 |
| [FilesName-md.bat](FilesName-md.bat) | 批处理 | 仅生成 Markdown 文件列表 |
| [FilesName-txt.bat](FilesName-txt.bat) | 批处理 | 仅生成树状结构文件 |
| [FileExcludeList.txt](FileExcludeList.txt) | 配置 | 排除文件列表配置 |
| [TempWebServ.bat](TempWebServ.bat) | 批处理 | 独立网络服务启动脚本 |

## 🚀 快速使用

### 方式一：批处理脚本（推荐）

```bash
# 运行主脚本（功能最全）
FilesName-html+web.bat

# 运行后按提示选择是否启动网络服务
# Y - 启动 Python HTTP 服务器
# H - 启动 HFS 服务器
# N - 跳过网络服务
```

### 方式二：PowerShell 脚本

```powershell
# 首次运行需设置执行策略
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

# 运行脚本
.\FilesName-html+web.ps1
```

### 方式三：独立功能脚本

```bash
# 仅生成 HTML+Markdown
FilesName-html.bat

# 仅生成 Markdown
FilesName-md.bat

# 仅生成树状结构
FilesName-txt.bat
```

## ⚙️ 配置说明

### 排除文件配置

编辑 [FileExcludeList.txt](FileExcludeList.txt) 文件，每行一个文件名：

```txt
# 注释行以 # 开头
FilesName-txt.bat
FilesName-md.bat
FileList.html
FileList.md
```

> 💡 **提示**：脚本文件自身和生成的输出文件默认会被排除

### 网络服务配置

| 选项 | 说明 | 要求 |
|------|------|------|
| **Y** | Python HTTP 服务器 | 需安装 Python |
| **H** | HFS 服务器 | 需下载 HFS 并放入 `HFS\hfs.exe` |
| **N** | 跳过，按 `Enter` 也可 | 无需额外配置 |

## 📋 输出文件

运行完成后会生成以下文件：

| 文件 | 格式 | 用途 |
|------|------|------|
| `FileList.txt` | 纯文本 | 树状目录结构 |
| `FileList.md` | Markdown | 带链接的文件列表 |
| `FileList.html` | HTML 网页 | 可视化文件列表（推荐在浏览器打开） |

## 🖼️ HTML 页面特性

- 📱 响应式设计，支持手机和桌面端
- 🎯 悬停效果和动画交互
- 🔍 清晰的目录分组展示
- 📊 显示文件总数统计
- 🌐 支持局域网共享访问

## ⚠️ 注意事项

1. **编码设置** - 脚本自动设置 UTF-8 编码（chcp 65001）
2. **路径空格** - 文件路径中的空格会自动编码为 `%20`
3. **权限要求** - 网络服务可能需要管理员权限
4. **端口占用** - 默认使用 8080 端口，如被占用请修改脚本
5. **Python 版本** - 建议使用 Python 3.x

## 🔧 自定义修改

### 修改端口号

在 [FilesName-html+web.bat](FilesName-html+web.bat) 中修改：

```bash
python -m http.server 8080
```
在 [FilesName-html+web.ps1](FilesName-html+web.ps1) 中修改：

```powershell
[int]$Port = 8080
```
### 修改 HTML 样式

编辑脚本中的 `<style>` 部分，自定义 CSS 样式。

### 添加排除文件

在 [FileExcludeList.txt](FileExcludeList.txt) 中添加文件名即可。

## 📝 示例输出

### Markdown 格式

```markdown
# File List

**Path:** D:\files_tree_tools
**Generated:** 2024/01/15 10:30:45

### files_tree_tools

- FilesName-html+web.bat [Open](./FilesName-html+web.bat)
- FileExcludeList.txt [Open](./FileExcludeList.txt)

---
**Total:** 8 files
```

### HTML 页面

打开 `FileList.html` 即可查看美观的文件列表网页，支持点击直接打开文件。

## 🆘 常见问题

**Q: 提示找不到 Python？**
> A: 请访问 https://www.python.org/ 下载安装 Python，并确保添加到系统 PATH

**Q: 网络服务无法启动？**
> A: 检查端口是否被占用，或尝试以管理员身份运行脚本

**Q: 排除配置不生效？**
> A: 确保 [FileExcludeList.txt](FileExcludeList.txt) 与脚本在同一目录，文件名完全匹配

## 📄 许可证

本工具集供个人和学习使用，采用 [MIT 许可证](LICENSE) 开源。

---

**🎉 使用愉快！如有问题欢迎反馈。**