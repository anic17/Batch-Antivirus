::BAV_:git@github.com:anic17/Batch-Antivirus.git
@echo off
setlocal EnableDelayedExpansion
set ver=3.0.2
title Batch Antivirus Scanner
if /i "%~1"=="--help" goto help

set admin=1

set scanned_files=0
set threats=0
if /i "%~1"=="--reg-scan" goto reg_scan
if /i "%~2"=="--skip-update" (
	goto skipupdate
)
net session > nul 2>&1 || set admin=0
if !admin!==0 (
	echo Looks like you are running Batch Antivirus without administrator permissions...
	echo.
	echo This can make difficult to remove some malware.
	echo It is recommended to run the scan as administrator.
	echo.
	echo.Would you like to run scan as administrator? ^(y/n^)
	choice /c:YN /n
	if !errorlevel!==1 goto runas
)

call "%~dp0BAVUpdate.bat"
:skipupdate

if "%~1"=="" (
	cd \
) else (
	cd /d "%~1" > nul 2>&1
)
echo.
echo Scanning '%CD%' for threats...
echo.
call :reg_scan
for /r %%A in (*) do call :scan "%%~A" 2>nul

:finished
echo Scan finished.
echo.
call :settitle
echo Result: !scanned_files! files scanned and !threats! threat(s) found
echo.
echo Press any key to quit...
pause>nul
exit /B %errorlevel%

:scan
set "filescan=%~1"
call :settitle
for /f %%A in ('sha256.exe "!filescan!" 2^>nul') do call :hashed %%A
set /a scanned_files+=1
goto :EOF

:hashed

set "hash=%~1"
set "hash=!hash:\=!"

findstr /c:"!hash!" "%~dp0VirusDataBaseHash.bav" > nul || goto :EOF

for /f "tokens=1* delims=:" %%a in ('findstr /c:"!hash!" "%~dp0VirusDataBaseHash.bav"') do (call :detection "%%~a" "%%~b")
goto :EOF

:detection
if "%~1" neq "!hash!" goto :EOF

start /b powershell [Reflection.Assembly]::LoadWithPartialName("""System.Windows.Forms""");$obj=New-Object Windows.Forms.NotifyIcon;$obj.Icon = [drawing.icon]::ExtractAssociatedIcon($PSHOME + """\powershell.exe""");$obj.Visible = $True;$obj.ShowBalloonTip(100000, """Batch Antivirus""","""Threats found: %~2""",2)>nul
echo Malware found: !filescan! ^| %~2
md "%~dp0Data\Quarantine\!hash!" > nul 2>&1
icacls "!filescan!" /setowner %username% > nul 2>&1
icacls "!filescan!" /grant %username%:(F,MA,WA,RA,WEA,REA,WDAC,DE) > nul 2>&1

move "!filescan!" "%~dp0Data\Quarantine\!hash!\!hash!" /y > nul 2>&1
icacls "%~dp0Data\Quarantine\!hash!\!hash!" /deny %username%:(RX,W,R,M,RD,WEA,REA,X,RA,WA) > nul 2>&1
set /a threats+=1
if not exist "!filescan!" (echo Malware successfully quarantined) else call :delete
goto :EOF

:delete
echo.
echo Failed to quarantine malware^^!
set /p "delmalware=Delete malware? (y/n): "
icacls "!filescan!" /setowner %username% > nul 2>&1
icacls "!filescan!" /grant %username%:(F,MA,WA,RA,WEA,REA,WDAC,DE) > nul 2>&1
if /i "%delmalware%"=="y" del !filescan! /s /q /f > nul
echo.
goto :EOF

:help
echo.
echo Batch Antivirus - Scanner
echo.
echo Syntax:
echo.
echo BAV [[folder] ^| --reg-scan ^| --help] [--skip-update]
echo.
echo Examples:
echo.
echo BAV
echo Will scan all the current drive. This may take some a lot of time depending
echo on the number of files and the computer performance.
echo.
echo BAV "%USERPROFILE%"
echo Will scan the folder "%USERPROFILE%" and all its subdirectories
echo It is recommended for a more precise and faster scan.
echo.
echo BAV --reg-scan
echo Only scan the autorun registry keys.
echo.
echo.BAV --skip-update
echo.Skip update checking and directly run scan.
echo.
echo BAV --help
echo Displays this help message.
echo.
echo Batch Antivirus will check at every startup new database updates to ensure you
echo have always the latest database.
echo.You can also manually check for updates by running 'BAVUpdate.bat' file.
echo.
echo Official GitHub repository:
echo https://github.com/anic17/Batch-Antivirus
echo.
echo If you accidentally downloaded some malware or PUP, contact batch.antivirus@gmail.com
echo and send the potentially malicious file via Mega, Dropbox, Google Drive, Mediafire or OneDrive.
echo.
echo Copyright (c) 2022 anic17 Software
endlocal
exit /B 0

:runas
powershell -ExecutionPolicy Bypass -Command Start-Process -FilePath """%~0""" -verb RunAs
exit /b

:reg_scan
:: Run keys

for %%A in (HKEY_LOCAL_MACHINE HKEY_CURRENT_USER) do (
	rem Run and RunOnce
	for /f "tokens=3* delims= " %%A in ('reg query "%%A\Software\Microsoft\Windows\CurrentVersion\Run"') do call :scan "%%~A"
	for /f "tokens=3* delims= " %%A in ('reg query "%%A\Software\Microsoft\Windows\CurrentVersion\RunOnce"') do call :scan "%%~A"
)
:: Run WOW6432Node
for /f "tokens=3* delims= " %%A in ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run"') do call :scan "%%~A"
for /f "tokens=3* delims= " %%A in ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\RunOnce"') do call :scan "%%~A"

:: Shell and userinit keys
for /f "tokens=3* delims= " %%A in ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v Userinit') do (
	for /f "tokens=1 delims=," %%X in ("%%~A") do call :scan "%%~X"
)
for /f "tokens=3* delims= " %%A in ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Winlogon" /v Userinit') do (
	for /f "tokens=1 delims=," %%X in ("%%~A") do call :scan "%%~X"
)
goto :EOF

:settitle
title Scanning now: !filescan! ; !scanned_files! scanned, !threats! threat(s) found