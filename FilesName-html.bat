@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

set "mdFile=FileList.md"
set "htmlFile=FileList.html"
set "currentDir=%cd%"
for %%A in ("%currentDir%") do set "rootFolderName=%%~nxA"

echo [1/4] Generating Markdown file...

:: ========== 生成 Markdown 文件 ==========
echo # File List > "%mdFile%"
echo. >> "%mdFile%"
echo **Path:** %currentDir% >> "%mdFile%"
echo **Generated:** %date% %time% >> "%mdFile%"
echo. >> "%mdFile%"

echo [2/4] Generating HTML file...

:: ========== 生成 HTML 文件（逐行写入，避免代码块问题） ==========
echo ^<!DOCTYPE html^> > "%htmlFile%"
echo ^<html lang="zh-CN"^> >> "%htmlFile%"
echo ^<head^> >> "%htmlFile%"
echo     ^<meta charset="UTF-8"^> >> "%htmlFile%"
echo     ^<meta name="viewport" content="width=device-width, initial-scale=1.0"^> >> "%htmlFile%"
:: echo     ^<title^>File List^</title^> >> "%htmlFile%"
echo     ^<title^>!rootFolderName! - File List^</title^> >> "%htmlFile%"
echo     ^<style^> >> "%htmlFile%"
echo         body { font-family: Arial, sans-serif; max-width: 1200px; min-width: 418px; margin: 0 auto; padding: 20px; background: #f5f5f5; } >> "%htmlFile%"
echo         .container { background: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); } >> "%htmlFile%"
echo         h1 { color: #333; border-bottom: 2px solid #0078d4; padding-bottom: 10px; } >> "%htmlFile%"
echo         h3 { color: #0078d4; margin-top: 30px; background: #e8f4fc; padding: 10px; border-radius: 4px; word-wrap: break-word;  word-break: break-all; display: block; } >> "%htmlFile%"
echo         .file-item { padding: 8px 12px; margin: 5px 0; border-radius: 4px; border-left: 3px solid transparent; transition: all 0.2s; word-wrap: break-word;  word-break: break-all; display: block; } >> "%htmlFile%"
echo         .file-item:hover { background: #f0f0f0; border-left-color: #d1e1f2; transform: translateX(5px); } >> "%htmlFile%"
echo         .open-btn { display: inline-block; padding: 4px 12px; background: #0078d4; color: white; border-radius: 4px; margin-left: 10px; text-decoration: none; font-size: 12px; } >> "%htmlFile%"
echo         .open-btn:hover { background: #005a9e; } >> "%htmlFile%"
echo         .meta { color: #666; font-size: 14px; margin-bottom: 20px; } >> "%htmlFile%"
echo         .total { margin-top: 30px; padding: 15px; background: #e8f4fc; border-radius: 4px; font-weight: bold; } >> "%htmlFile%"
echo     ^</style^> >> "%htmlFile%"
echo ^</head^> >> "%htmlFile%"
echo ^<body^> >> "%htmlFile%"
echo     ^<div class="container"^> >> "%htmlFile%"
echo         ^<h1^>📁 File List^</h1^> >> "%htmlFile%"
echo         ^<div class="meta"^> >> "%htmlFile%"
echo             ^<strong^>📍 Path:^</strong^> %currentDir%^<br^> >> "%htmlFile%"
echo             ^<strong^>🕐 Generated:^</strong^> %date% %time% >> "%htmlFile%"
echo         ^</div^> >> "%htmlFile%"

echo [3/4] Scanning files...

set "count=0"
:: 修改初始值（关键！）
set "currentFolder=__INIT__"

:: 读取排除列表到变量
set "excludeConfig=FileExcludeList.txt"
set "excludeList= "

if exist "%excludeConfig%" (
    for /f "usebackq tokens=1 delims=" %%a in (`findstr /v /r /c:"^#" /c:"^$" "%excludeConfig%" 2^>nul`) do (
        set "excludeList=!excludeList!%%a "
    )
    @REM echo [INFO] 已加载排除配置：%excludeConfig%
) else (
    echo [WARN] 未找到 %excludeConfig%，使用默认排除规则
)
:: echo [DEBUG] Exclude List: !excludeList!

:: 递归处理所有文件
for /f "delims=" %%i in ('dir /s /b *.* 2^>nul') do (
    set /a count+=1
    set "fullPath=%%i"
    set "relPath=%%i"
    set "relPath=!relPath:%currentDir%\=!"
    
    for %%f in ("%%i") do set "fileName=%%~nxf"
    
    set "folderPath=%%~dpi"
    set "folderRel=!folderPath:%currentDir%\=!"
    if "!folderRel!" neq "" set "folderRel=!folderRel:~0,-1!"
    
    set "skip=0"
    @REM if /i "!fileName!"=="FilesName-txt.bat" set "skip=1"
    @REM if /i "!fileName!"=="FilesName-md.bat" set "skip=1"
    @REM if /i "!fileName!"=="FilesName-html.bat" set "skip=1"
    @REM if /i "!fileName!"=="FilesName-html+web.bat" set "skip=1"
    @REM if /i "!fileName!"=="FilesName-html+web.ps1" set "skip=1"
    @REM if /i "!fileName!"=="WebTempPage.bat" set "skip=1"
    @REM if /i "!fileName!"=="FileList.txt" set "skip=1"
    @REM if /i "!fileName!"=="FileList.md" set "skip=1"
    @REM if /i "!fileName!"=="index.html" set "skip=1"
    if "!excludeList!" neq " " (
        for %%e in (!excludeList!) do (
            if /i "!fileName!"=="%%e" set "skip=1"
        )
    )
    
    if "!skip!"=="0" (
        :: 目录变化时显示新目录标题
        if "!folderRel!" neq "!currentFolder!" (
            if "!folderRel!"=="" (
                :: echo         ^<h3^>Root^</h3^> >> "%htmlFile%"
                echo         ^<h3^>!rootFolderName!^</h3^> >> "%htmlFile%"
                echo. >> "%mdFile%"
                :: echo ### Root >> "%mdFile%"
                echo ### !rootFolderName! >> "%mdFile%"
                echo. >> "%mdFile%"
            ) else (
                echo         ^<h3^>!folderRel!^</h3^> >> "%htmlFile%"
                echo. >> "%mdFile%"
                echo ### !folderRel! >> "%mdFile%"
                echo. >> "%mdFile%"
            )
            set "currentFolder=!folderRel!"
        )
        
        :: 路径编码
        set "encPath=!relPath:\=/!"
        set "encPath=!encPath: =%%20!"
        
        :: 输出文件项到 HTML
        echo         ^<div class="file-item"^>^<span^>!fileName!^</span^> ^<a href="./!encPath!" class="open-btn"^>Open^</a^>^</div^> >> "%htmlFile%"
        
        :: 输出文件项到 MD
        echo - !fileName! [Open](./!encPath!^) >> "%mdFile%"
    )
)

echo [4/4] Finalizing...

:: 关闭 HTML 标签
echo         ^<div class="total"^>Total: %count% files^</div^> >> "%htmlFile%"
echo     ^</div^> >> "%htmlFile%"
echo ^</body^> >> "%htmlFile%"
echo ^</html^> >> "%htmlFile%"

:: 写入 MD 统计
echo. >> "%mdFile%"
echo --- >> "%mdFile%"
echo **Total:** %count% files >> "%mdFile%"

echo.
echo ========================================
echo ✅ Generation Complete!
echo ========================================
echo Total: %count% files
echo.
echo Generated files:
echo   1. FileList.txt   (Tree structure)
echo   2. FileList.md    (Markdown format)
echo   3. FileList.html  (HTML format - Recommended)
echo.
echo Tip: Open FileList.html in your browser.
echo ========================================
echo.

@REM WebTempPage.bat
set "webpageConfig=WebTempPage.bat"

if exist "%webpageConfig%" (
    WebTempPage.bat
)

:: pause