::!BAV_
@echo off
setlocal EnableDelayedExpansion
set dir=%CD%
path=%PATH%;%CD%
set ver=0.1.0
title Batch AntiVirus
if /i "%~1"=="--help" goto help
set elements=files

color 07
set admin=1

mode con: cols=120 lines=30
set scanned_files=0
set threats=0
if /i "%~1"=="--prompt-scan" goto prompt_scan
if /i "%~1"=="--reg-scan" goto reg_scan
if /i "%~2"=="--skip-update" (
	call :scan "%~f1"
	exit /b
)

:database_check
echo Checking for database updates...



md "%TMP%\Batch-AntiVirus" 2>nul 1>nul

takeown /f "%TMP%\Batch-AntiVirus" 2>nul 1>nul
icacls "%TMP%\Batch-AntiVirus" /setowner "%username%" 2>nul 1>nul

icacls "%TMP%\Batch-AntiVirus" /grant "%username%":(F,MA) /t 2>nul 1>nul

powershell -Command Invoke-WebRequest -Uri "https://raw.githubusercontent.com/anic17/Batch-AntiVirus/master/VirusDataBaseHash.bav" -OutFile "%TMP%\Batch-AntiVirus\VirusDataBaseHash.bav"
rem for /f %%H in ('sha256 "%TMP%\Batch-AntiVirus\VirusDataBaseHash.bav"') do (set "hashnewdatabase=%%H")
rem for /f %%H in ('sha256 "VirusDataBaseHash.bav"') do (set "hasolddatabase=%%h")

rem if /i "%hashnewdatabase%" neq "%hasolddatabase%" (
rem 	echo Update found: Installing...
rem 	move "%~dp0VirusDataBaseHash.bav" "%~dp0VirusDataBaseHash.bav.old" /y 2>nul 1>nul
rem ) else (
rem 		echo No update found
rem )

net session 2>nul 1>nul || set admin=0
if !admin!==0 (
	echo Looks like you are running Antivirus without administrator permissions...
	echo.
	echo This can make difficult to remove some malware.
	echo We recommend running it as administrator
	echo.
	set /p "runasdmin_ask=Would you like to run scan as administrator? (y/n): "
	if /i not !runasdmin_ask!==n goto runas
)

echo.
echo Scanning system for threats...
echo.
set "current_dir=%CD%"
cd/
if "%~1" neq "" cd /d "%~1"
if /i "%~1"=="--current-dir" cd /d "%current_dir%"

call :reg_scan
for /r %%a in (*.*) do call :scan "%%~a" 2> nul
:finished
echo Scan finished.
echo.
echo Result: !scanned_files! scanned %elements% and !threats! threat(s) found
echo.
echo Press any key to quit...
pause>nul
exit /B %errorlevel%

:scan
title Scanning now: %* ; !scanned_files! scanned %elements%, !threats! threat(s) found
set filescan=%*
for /f %%A in ('sha256.exe "%~1" 2^>nul') do (call :hashed %%A)
set /a scanned_files+=1
goto :EOF

:hashed

set "hash=%~1"
set "hash=%hash:~1%"

findstr /c:"%hash%" "%~dp0VirusDataBaseHash.bav" > nul || exit /B

for /f "tokens=1,2* delims=:" %%a in ('findstr /c:"%hash%" "%~dp0VirusDataBaseHash.bav"') do (call :detection "%%~a" "%%~b")
goto :EOF

:detection
if "%~1" neq "%hash%" goto :EOF

start /b powershell [Reflection.Assembly]::LoadWithPartialName("""System.Windows.Forms""");$obj=New-Object Windows.Forms.NotifyIcon;$obj.Icon = [drawing.icon]::ExtractAssociatedIcon($PSHOME + """\powershell.exe""");$obj.Visible = $True;$obj.ShowBalloonTip(100000, """Batch Antivirus""","""Threats found: %~2""",2)>nul
if "%~1"=="%hash%" (echo Malware found: !filescan! ^| %~2) || goto :EOF
md "%DIR%\Data\Quarantine\!hash!" 2>nul 1>nul
icacls %filescan% /setowner %username% 2>nul 1>nul
icacls %filescan% /grant %username%:(F,MA,WA,RA,WEA,REA,WDAC,DE) 2>nul 1>nul

move %filescan% "%DIR%\Data\Quarantine\!hash!\!hash!" /y 2>nul 1>nul
icacls "%DIR%\Data\Quarantine\!hash!\!hash!" /deny %username%:(RX,W,R,M,RD,WEA,REA,X,RA,WA) 2>nul 1>nul
set /a threats+=1
if not exist %filescan% (echo Malware successfully quarantined) else (call :delete)
goto :EOF

:delete
echo.
echo Failed to quarantine malware^^!
set /p "delmalware=Delete malware? (y/n): "
icacls %filescan% /setowner %username% 2>nul 1>nul
icacls %filescan% /grant %username%:(F,MA,WA,RA,WEA,REA,WDAC,DE) 2>nul 1>nul
if /i "%delmalware%"=="y" del !filescan! /s /q > nul
echo.
goto :EOF

:help
echo.
echo Batch AntiVirus %ver% - Help menu
echo.
echo Syntax:
echo.
echo BAV "[folder]"
echo BAV [--switch]
echo.
echo Examples:
echo.
echo BAV
echo Will do an scan in all current drive. This may take some time depending
echo of the number of files and the speed of your computer.
echo.
echo BAV "%USERPROFILE%"
echo Will scan the folder "%USERPROFILE%" and all it's subdirectories
echo It is recommended for more precise scan
echo.
echo BAV --reg-scan
echo Will only scan the registry looking for threats
echo.
echo BAV --prompt-scan
echo Will make a scan of current directory while you can use CMD,
echo running in background but seeing results. Useful if you want to continue working
echo while a scan is running
echo.
echo BAV --help
echo Will show this message
echo.
echo.
echo Batch AntiVirus will check at every startup new database updates to guarantee
echo that you have always the most updated database
echo.
echo Official GitHub repository:
echo https://github.com/anic17/Batch-AntiVirus
echo.
echo If you accidentally downloaded some malware or PUP, contact batch.antivirus@gmail.com
echo and send the potentially malicious file via Mega, Dropbox, Google Drive, Mediafire or OneDrive.
echo.
echo.
echo Copyright (c) 2020 anic17 Software
endlocal
exit /B 0



:prompt_scan
start /b "" cmd.exe /c "%~0" --current-dir & cd /d "%CD%" & exit 0

:runas
echo CreateObject("Shell.Application").ShellExecute ""%~nx0 %*"",,,"RunAs",1 > "%TMP%\BAV-RunAs.vbs"
cscript.exe //nologo "%TMP%\BAV-RunAs.vbs" //B & exit /B %errorlevel%

:reg_scan
set elements=elements
:: Run keys

for /f "tokens=3* delims= " %%A in ('reg query "HKLM\Software\Microsoft\Windows\CurrentVersion\Run"') do (call :scan %%A %%B)
for /f "tokens=3* delims= " %%A in ('reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Run"') do (call :scan %%A %%B)

:: RunOnce keys
for /f "tokens=3* delims= " %%A in ('reg query "HKLM\Software\Microsoft\Windows\CurrentVersion\RunOnce"') do (call :scan %%A %%B)
for /f "tokens=3* delims= " %%A in ('reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\RunOnce"') do (call :scan %%A %%B)

:: Run WOW6432Node
for /f "tokens=3* delims= " %%A in ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run"') do (call :scan %%A %%B)
for /f "tokens=3* delims= " %%A in ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\RunOnce"') do (call :scan %%A %%B)

:: Shell and userinit keys
for /f "tokens=3* delims= " %%A in ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"') do (call :scan %%A %%B)
for /f "tokens=3* delims= " %%A in ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Winlogon"') do (call :scan %%A %%B)


