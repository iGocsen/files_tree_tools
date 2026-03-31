@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

set "outputFile=FileList.md"
set "currentDir=%cd%"
for %%A in ("%currentDir%") do set "rootFolderName=%%~nxA"

:: 创建文件头
echo # File List > "%outputFile%"
echo/ >> "%outputFile%"
echo **Path:** %currentDir% >> "%outputFile%"
echo **Generated:** %date% %time% >> "%outputFile%"
echo/ >> "%outputFile%"

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
    
    :: 获取文件名（正确方式）
    for %%f in ("%%i") do set "fileName=%%~nxf"
    
    :: 获取纯目录路径（使用 %%~dpi 而不是 %%~dpf）
    set "folderPath=%%~dpi"
    set "folderRel=!folderPath:%currentDir%\=!"
    :: 移除末尾反斜杠
    if "!folderRel!" neq "" set "folderRel=!folderRel:~0,-1!"
    
    :: 跳过输出文件和批处理文件
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
            echo/ >> "%outputFile%"
            if "!folderRel!"=="" (
                echo ### !rootFolderName! >> "%outputFile%"
            ) else (
                echo ### !folderRel! >> "%outputFile%"
            )
            echo/ >> "%outputFile%"
            set "currentFolder=!folderRel!"
        )
        
        :: 路径编码：反斜杠转正斜杠，空格转%%20
        set "encPath=!relPath:\=/!"
        set "encPath=!encPath: =%%20!"
        
        :: 输出文件链接
        echo - !fileName! [Open](./!encPath!^) >> "%outputFile%"
    )
)

echo/ >> "%outputFile%"
echo --- >> "%outputFile%"
echo **Total:** %count% files >> "%outputFile%"

echo Total: %count% files done. 
echo.
echo Stored in the two files below:
echo 1. FileList.txt
echo 2. FileList.md
echo.
pause