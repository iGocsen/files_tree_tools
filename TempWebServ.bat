@echo off
chcp 65001 >nul

:: ========== 网络服务选项 ==========
echo 是否启动临时网络服务让其他设备访问？
echo   Y - Start Python HTTP server
echo   H - Start HFS server (Windows only, requires HFS)
echo   N - Skip network server
echo.
set /p "serverChoice=请选择 (Y/H/N): "

if /i "!serverChoice!"=="Y" (
    call :StartPythonServer
) else if /i "!serverChoice!"=="H" (
    call :StartHFSServer
) else (
    echo 已跳过启动网络服务
)

echo.
pause
exit /b

:: ========== Python 服务器 ==========
:StartPythonServer
echo.
echo [正在检查 Python...]
python --version >nul 2>&1
if errorlevel 1 (
    echo [错误] 未检测到 Python，请先安装 Python
    echo 下载地址：https://www.python.org/
    pause
    exit /b
)

echo [Python 已就绪]
echo.

:: 获取本机 IP
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /c:"IPv4"') do (
    set "localIp=%%a"
    set "localIp=!localIp: =!"
    goto :gotIp2
)
:gotIp2

echo ========================================
echo  临时 HTTP 服务器已启动
echo ========================================
echo.
echo 访问地址:
echo   本机访问：http://localhost:8080
echo   局域网访问：http://!localIp!:8080
echo.
echo 其他设备请在浏览器输入上述地址
echo 按 Ctrl+C 停止服务
echo ========================================
echo.

python -m http.server 8080
goto :eof

:: ========== HFS 服务器 ==========
:StartHFSServer
echo.
echo [正在检查 HFS...]
if not exist "HFS\hfs.exe" (
    echo [错误] 未找到 HFS
    echo 请下载地址：https://www.rejetto.com/hfs/
    echo 将 hfs.exe 放入 HFS 文件夹
    pause
    exit /b
)

echo [HFS 已就绪]
start "" "HFS\hfs.exe"
echo HFS 已启动，请在 HFS 界面中拖入文件
goto :eof