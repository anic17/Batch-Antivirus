::BAV_:git@github.com:anic17/Batch-Antivirus.git
@echo off
setlocal EnableDelayedExpansion
title Batch Antivirus Disk Scanner
if /i "%~1"=="--help" goto help

call "%~dp0BAVStatus.bat" --skip || exit /b
call "%~dp0BAVConfig.bat" - 
set admin=1

set scanned_files=0
set threats=0
for %%A in (
	"reg-scan"
	"process-scan"
	"skip-update"
) do (
	if /i "%~1"=="--%%~A" goto :%%~A
	if /i "%~2"=="--%%~A" goto :%%~A
	if /i "%~3"=="--%%~A" goto :%%~A
	if /i "%~4"=="--%%~A" goto :%%~A
	
)

net session > nul 2>&1 || set admin=0
if "!admin!" equ "0" (
	echo.Batch Antivirus is currently running without administrator privileges.
	echo.
	echo This can make it difficult to remove some malicious files. Therefore,
	echo.it is strongly advised to execute the scan as an administrator.
	echo.
	echo.Would you like to rerun this scan as an adminstrator? ^(y/n^)
	choice /c:YN /n
	if !errorlevel!==1 goto runas
)
:skipadmin
call "%~dp0BAVUpdate.bat" --skip
:skip-update

if "%~1"=="" (
	pushd \
) else (
	pushd "%~1" > nul 2>&1 || (
		echo.Unable to scan the directory '%~1'
		goto quit
	)
)

echo.
echo.Scanning the registry...
echo.
call :reg-scan
echo.
echo.Scanning all the currently running processes...
call :process-scan
echo.
echo Scanning '%CD%' for threats...
echo.
for /r %%A in (*) do call :scan "%%~A" 2>nul

:finished
echo Scan finished.
echo.
call :settitle
echo Result: !scanned_files! files scanned and !threats! threat(s) found
echo.
:quit
echo Press any key to quit...
pause>nul
exit /B %errorlevel%

:scan
set "filescan=%~1"
if not exist "!filescan!" goto :EOF
set "fs_basename=%~nx1"
call :settitle

for /f %%A in ('sha256.exe "!filescan!" 2^>nul') do call :hashed %%A %~2
set /a scanned_files+=1
goto :EOF

:hashed

set "hash=%~1"
if not defined hash for /f %%A in ('certutil -hashfile "!filescan!" SHA256 ^| findstr /vc:"h"') do set "hash=%%~A"
set "hash=!hash:\=!"
findstr /c:"!hash!" "%~dp0VirusDataBaseHash.bav" > nul || goto :EOF

for /f "tokens=1* delims=:" %%a in ('findstr /c:"!hash!" "%~dp0VirusDataBaseHash.bav"') do (call :detection "%%~a" "%%~b" %~2)
goto :EOF

:detection
if "%~1" neq "!hash!" goto :EOF

start /b powershell [Reflection.Assembly]::LoadWithPartialName("""System.Windows.Forms""");$obj=New-Object Windows.Forms.NotifyIcon;$obj.Icon = [drawing.icon]::ExtractAssociatedIcon($PSHOME + """\powershell.exe""");$obj.Visible = $True;$obj.ShowBalloonTip(100000, """Batch Antivirus""","""Threats found: %~2""",2)>nul
echo Malware found: !filescan! ^| %~2

md "%~dp0Data\Quarantine\!hash!" > nul 2>&1
icacls "!filescan!" /setowner %username% > nul 2>&1
icacls "!filescan!" /grant %username%:(F,MA,WA,RA,WEA,REA,WDAC,DE) > nul 2>&1

move /y "!filescan!" "%~dp0Data\Quarantine\!hash!\!hash!_" > nul 2>&1 && certutil -encode -f "%~dp0Data\Quarantine\!hash!\!hash!_" "%~dp0Data\Quarantine\!hash!\!hash!" > nul 2>&1 && del "%~dp0Data\Quarantine\!hash!\	!hash!_" /q > nul 2>&1

icacls "%~dp0Data\Quarantine\!hash!\!hash!" /deny %username%:(RX,W,R,M,RD,WEA,REA,X,RA,WA) > nul 2>&1
echo.%~2 > "%~dp0Data\Quarantine\!hash!\detection"
<nul set /p "=!filescan!" > "%~dp0Data\Quarantine\!hash!\name"

set /a threats+=1
if "%~3"=="true" taskkill /f /im "!fs_basename!" > nul 2>&1 && (echo Successfully killed the malware process '!fs_basename!') || (echo Failed to kill the malware process '!fs_basename!')

if not exist "!filescan!" (echo Malware successfully quarantined) else call :delete %~2
goto :EOF

:delete <detection>
echo.
echo Failed to quarantine malware^^!
set /p "delmalware=Delete malware? (y/n): "
icacls "!filescan!" /setowner %username% > nul 2>&1
icacls "!filescan!" /grant %username%:(F,MA,WA,RA,WEA,REA,WDAC,DE) > nul 2>&1
if /i "%delmalware%"=="y" (
	del !filescan! /s /q /f > nul && (
		echo.Successfully removed the malware %~1
	) || (
		echo.Failed to remove malware %~1
	)
)
echo.
goto :EOF

:help
echo.
echo Batch Antivirus - Disk Scanner
echo.
echo Syntax:
echo.
echo BAV [[folder] ^| --reg-scan ^| --process-scan ^| --help] [--skip-update]
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
echo If you find some malware, contact batch.antivirus@gmail.com and send the malicious file hash.
echo.
echo Copyright (c) 2025 anic17 Software
endlocal
exit /b 0

:runas
powershell -ExecutionPolicy Bypass -Command Start-Process -FilePath """%~0""" -verb RunAs
if "%errorlevel%" neq "0" (
	echo.Failed to start Batch Antivirus Disk Scanner with administrator privileges
	echo.
	goto skipadmin
)
exit /b

:reg-scan
:: Run keys
echo.Scanning the autoruns...
for %%A in (HKEY_LOCAL_MACHINE HKEY_CURRENT_USER) do (
	rem Run and RunOnce
	for /f "tokens=2* skip=2 delims= " %%A in ('reg query "%%A\Software\Microsoft\Windows\CurrentVersion\Run"') do call :scan "%%~B"
	for /f "tokens=2* skip=2 delims= " %%A in ('reg query "%%A\Software\Microsoft\Windows\CurrentVersion\RunOnce"') do call :scan "%%~B"
)
:: Run WOW6432Node

for /f "tokens=2* skip=2 delims= " %%A in ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run"') do call :scan "%%~B"
for /f "tokens=2* skip=2 delims= " %%A in ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\RunOnce"') do call :scan "%%~B"

:: Shell and userinit keys
echo.Scanning Userinit key...

for /f "tokens=2* skip=2 delims= " %%A in ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v Userinit') do (
	for /f "tokens=1 delims=," %%X in ("%%~B") do call :scan "%%~X"
	for /f "tokens=1 delims=," %%X in ("%%~B") do call :scan "%systemroot%\%%~X"
	
)
echo.Scanning Shell key...
for /f "tokens=2* skip=2 delims= " %%A in ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Winlogon" /v Shell') do (
	for /f "tokens=1 delims=," %%X in ("%%~B") do call :scan "%%~X"
	for /f "tokens=1 delims=," %%X in ("%%~B") do call :scan "%systemroot%\%%~X"
	
)
goto :EOF

:process-scan

for /f "delims=" %%A in ('wmic process get ExecutablePath ^| findstr /vlc:"ExecutablePath" ^| sort /uniq') do for /f "delims=" %%B in ("%%A") do call :scan "%%~dpnxB" true
goto :EOF

:settitle
title Scanning now: !filescan! ; !scanned_files! scanned, !threats! threat(s) found
echo.Scanning: !filescan! >> "!logfile!"
