# Save as: FilesName-html+web.ps1
# # 使用说明
# Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
# # 以管理员身份运行此命令
# netsh http add urlacl url=http://+:8080/ user=Everyone
param(
    [string]$OutputDir = ".",
    [int]$Port = 8080
)

# ========== 函数定义 ==========
function Get-ContentType {
    param([string]$filePath)
    $ext = [System.IO.Path]::GetExtension($filePath).ToLower()
    switch ($ext) {
        ".html" { return "text/html" }
        ".css" { return "text/css" }
        ".js" { return "application/javascript" }
        ".json" { return "application/json" }
        ".png" { return "image/png" }
        ".jpg" { return "image/jpeg" }
        ".gif" { return "image/gif" }
        ".txt" { return "text/plain" }
        ".md" { return "text/markdown" }
        default { return "application/octet-stream" }
    }
}

function Start-LocalServer {
    param(
        [int]$Port,
        [string]$Path
    )
    
    $listener = New-Object System.Net.HttpListener
    # $prefix = "http://+:$Port/"
    $prefix = "http://localhost:$Port/"
    $listener.Prefixes.Add($prefix)
    
    try {
        $listener.Start()
        Write-Host "  监听中：$prefix" -ForegroundColor Green
        
        while ($listener.IsListening) {
            $context = $listener.GetContext()
            $request = $context.Request
            $response = $context.Response
            
            $relativePath = $request.Url.LocalPath.TrimStart('/')
            if ([string]::IsNullOrEmpty($relativePath)) { $relativePath = "FileList.html" }
            
            $filePath = Join-Path $Path $relativePath
            
            if (Test-Path $filePath) {
                $bytes = [System.IO.File]::ReadAllBytes($filePath)
                $response.ContentType = Get-ContentType $filePath
                $response.ContentLength64 = $bytes.Length
                $response.OutputStream.Write($bytes, 0, $bytes.Length)
            } else {
                $response.StatusCode = 404
                $errorMsg = "404 Not Found"
                $bytes = [System.Text.Encoding]::UTF8.GetBytes($errorMsg)
                $response.ContentLength64 = $bytes.Length
                $response.OutputStream.Write($bytes, 0, $bytes.Length)
            }
            $response.Close()
        }
    } catch {
        Write-Host "  启动失败：$_" -ForegroundColor Red
        Write-Host "  提示：可能需要管理员权限或端口被占用" -ForegroundColor Yellow
    } finally {
        # 增加检查，确保监听器存在且未释放
        if ($listener -ne $null) {
            try {
                if ($listener.IsListening) { $listener.Stop() }
                $listener.Close()
            } catch {
                # 忽略清理过程中的错误
            }
        }
    }
}

# ========== 主脚本 ==========
$ErrorActionPreference = "Continue"
$mdFile = "FileList.md"
$htmlFile = "FileList.html"
$txtFile = "FileList.txt"
$scriptName = $MyInvocation.MyCommand.Name

# 读取排除列表配置文件
$excludeConfig = "FileExcludeList.txt"
$excludeFiles = @()
$excludeFolders = @()

if (Test-Path $excludeConfig) {
    $lines = Get-Content $excludeConfig | Where-Object { 
        $_ -notmatch '^\s*#' -and $_ -notmatch '^\s*$' 
    }
    
    foreach ($line in $lines) {
        $item = $line.Trim()
        if ($item.StartsWith("/")) {
            $excludeFolders += $item.TrimStart("/")
        } else {
            $excludeFiles += $item
        }
    }
    Write-Host "  已加载排除配置：$($excludeFiles.Count) 项文件，$($excludeFolders.Count) 项文件夹" -ForegroundColor Gray
} else {
    # 默认排除列表
    $excludeFiles = @(
        $scriptName, "FileExcludeList.txt", "FileList.md", "FileList.html", "FileList.txt", 
        "FilesName-txt.bat", "FilesName-md.bat", "FilesName-html.bat", 
        "FilesName-html+web.bat", "FilesName-html+web.ps1", "WebTempPage.bat", "index.html"
    )
    Write-Host "  使用默认排除列表：$($excludeFiles.Count) 项" -ForegroundColor Gray
}

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  开始生成文件列表..." -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

Write-Host "[1/4] 生成树状结构文件..." -ForegroundColor Gray
tree /f > $txtFile

Write-Host "[2/4] 扫描当前目录文件..." -ForegroundColor Gray
$currentPath = (Get-Location).Path
# 动态获取当前根文件夹名称
$rootFolderName = Split-Path $currentPath -Leaf

# $allFiles = Get-ChildItem -Path $OutputDir -Recurse -File -ErrorAction SilentlyContinue | 
#     Where-Object { $excludeFiles -notcontains $_.Name }

# 扫描所有文件
$allFiles = Get-ChildItem -Path $OutputDir -Recurse -File -ErrorAction SilentlyContinue
# 应用排除规则
if ($excludeFiles.Count -gt 0 -or $excludeFolders.Count -gt 0) {
    $allFiles = $allFiles | Where-Object { 
        $excludeFiles -notcontains $_.Name -and
        ($excludeFolders.Count -eq 0 -or ($_.DirectoryName -split '\\') -notmatch ($excludeFolders -join '|'))
    }
}
# Write-Host "  共扫描到 $($allFiles.Count) 个文件" -ForegroundColor Gray

$totalCount = $allFiles.Count
$fileListHtml = ""
$fileListMd = ""

$groupedFiles = $allFiles | Group-Object DirectoryName

foreach ($group in $groupedFiles) {
    $folderName = $group.Name
    $relFolder = $folderName.Replace($currentPath, "").TrimStart("\")
    # if ($relFolder -eq "") { $relFolder = "Root" }
    if ($relFolder -eq "") { $relFolder = $rootFolderName }
    
    $fileListMd += "`n### $relFolder`n`n"
    $fileListHtml += "<h3>$relFolder</h3>`n<ul>`n"
    
    foreach ($file in $group.Group) {
        $fileName = $file.Name
        $relPath = $file.FullName.Replace($currentPath, "").TrimStart("\")
        $encPath = $relPath.Replace("\", "/").Replace(" ", "%20")
        
        $fileListMd += "- $fileName [Open](./$encPath)`n"
        $fileListHtml += "  <li><span class='icon'>📄</span>$fileName <a href='./$encPath' class='btn'>Open</a></li>`n"
    }
    $fileListHtml += "</ul>`n"
}

Write-Host "[3/4] 生成 Markdown 文件..." -ForegroundColor Gray
$mdContent = @"
# File List

**Path:** $currentPath
**Generated:** $(Get-Date -Format 'yyyy/MM/dd HH:mm:ss')

$fileListMd

---
**Total:** $totalCount files
"@
$mdContent | Out-File -FilePath $mdFile -Encoding UTF8

Write-Host "[4/4] 生成 HTML 文件..." -ForegroundColor Gray
$html = @"
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>$rootFolderName - File List</title>
    <style>
        body { font-family: 'Segoe UI', Arial, sans-serif; max-width: 1200px; min-width: 418px; margin: 0 auto; padding: 20px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); min-height: 100vh; }
        .container { background: white; padding: 40px; border-radius: 12px; box-shadow: 0 10px 40px rgba(0,0,0,0.2); }
        h1 { color: #333; border-bottom: 3px solid #667eea; padding-bottom: 15px; }
        h3 { color: #667eea; margin-top: 35px; background: linear-gradient(135deg, #e8f4fc 0%, #f0e8fc 100%); padding: 12px; border-radius: 6px; border-left: 4px solid #667eea; }
        ul { list-style: none; padding: 0; }
        li { padding: 10px 15px; margin: 6px 0; border-radius: 6px; border-left: 3px solid transparent; transition: all 0.2s}
        li:hover { background: #f8f9fa; border-left-color: #667eea; transform: translateX(5px); }
        a { color: #333; text-decoration: none; font-weight: 500; }
        a:hover { color: #667eea; }
        .btn { display: inline-block; padding: 5px 15px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; border-radius: 6px; margin-left: 15px; font-size: 13px; box-shadow: 0 2px 10px rgba(102,126,234,0.3); }
        .btn:hover { background: linear-gradient(135deg, #764ba2 0%, #667eea 100%); color: white; text-decoration: none; box-shadow: 0 4px 15px rgba(102,126,234,0.4); }
        .meta { color: #666; font-size: 14px; margin-bottom: 25px; padding: 15px; background: #f8f9fa; border-radius: 6px; }
        .total { margin-top: 35px; padding: 20px; background: linear-gradient(135deg, #e8f4fc 0%, #f0e8fc 100%); border-radius: 8px; font-weight: bold; color: #667eea; text-align: center; }
        .icon { margin-right: 10px; }
    </style>
</head>
<body>
    <div class="container">
        <h1>📁 File List</h1>
        <div class="meta">
            <strong>📍 Path:</strong> $currentPath<br>
            <strong>🕐 Generated:</strong> $(Get-Date -Format 'yyyy/MM/dd HH:mm:ss')
        </div>
        $fileListHtml
        <div class="total">Total: $totalCount files</div>
    </div>
</body>
</html>
"@
$html | Out-File -FilePath $htmlFile -Encoding UTF8

Write-Host "✅ 生成完成！" -ForegroundColor Green
Write-Host "   - $txtFile" -ForegroundColor Gray
Write-Host "   - $mdFile" -ForegroundColor Gray
Write-Host "   - $htmlFile" -ForegroundColor Gray
Write-Host "==================================================" -ForegroundColor Cyan

Write-Host "`n 是否启动临时网络服务让其他设备访问？" -ForegroundColor Yellow
Write-Host "   Y - 启动 PowerShell 内置 HTTP 服务器 (推荐)"
Write-Host "   N - 跳过"
$serverChoice = Read-Host "Enter choice (Y/N)"

if ($serverChoice -eq 'Y' -or $serverChoice -eq 'y') {
    $localIp = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -notlike "*Loopback*" | Select-Object -First 1 }).IPAddress
    if (-not $localIp) { $localIp = "localhost" }

    Write-Host "`n==================================================" -ForegroundColor Gray
    Write-Host "  临时 HTTP 服务器已启动，按 Ctrl+C 停止服务" -ForegroundColor Gray
    Write-Host "==================================================" -ForegroundColor Gray
    Write-Host "  访问地址:" -ForegroundColor Gray
    Write-Host "   本机访问：http://localhost:$Port" -ForegroundColor Cyan
    Write-Host "   局域网访问：http://$($localIp):$Port" -ForegroundColor Cyan
    # 在显示访问地址的部分，根据前缀动态提示
    # if ($prefix -like "*localhost*") {
    #     Write-Host "   本机访问：http://localhost:$Port" -ForegroundColor Cyan
    #     Write-Host "   ⚠  当前模式不支持局域网访问" -ForegroundColor Yellow
    # } else {
    #     Write-Host "   本机访问：http://localhost:$Port" -ForegroundColor Cyan
    #     Write-Host "   局域网访问：http://$($localIp):$Port" -ForegroundColor Cyan
    # }
    Write-Host "`n  其他设备请在浏览器输入上述地址" -ForegroundColor Gray
    # Write-Host "  按 Ctrl+C 停止服务" -ForegroundColor Gray
    Write-Host "==================================================`n" -ForegroundColor Gray

    Start-LocalServer -Port $Port -Path $OutputDir
} else {
    Write-Host "已跳过启动网络服务" -ForegroundColor Gray
}

Write-Host "`n 脚本执行完毕" -ForegroundColor Gray