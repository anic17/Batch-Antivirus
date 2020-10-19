::BAV_:git@github.com:anic17/Batch-Antivirus.git
@echo off
for %%A in ("--help" "/?" "-?" "-h" "-help" "/help" "/h") do if "%~1"=="%%~A" (
	echo.
	echo Batch Antivirus Real-Time Protection Engine
	echo.
	echo Usage:
	echo.
	echo Syntax:
	echo %~n0 [--ip ^| --fs] [drive]
	echo.
	echo Examples:
	echo.
	echo %~n0 --ip
	echo Will start web protection
	echo.
	echo %~n0 --fs F:\
	echo Will protect at drive F:
	echo.
	echo Copyright ^(c^) 2020 anic17 Software
	exit /b
)
if not defined threads set threads=3

setlocal EnableDelayedExpansion

md "%~dp0Data\Quarantine" > nul 2>&1
set "dir=%CD%"


for /f "tokens=2 delims= " %%A in ("%date%") do set "date_=%%A"
set "date_=%date_:/=-%"

::Start settings
::
:: Don't mess up with settings, it might leave your system unprotected
::
::


:: Graphical settings
set bav_rt_title=Batch Antivirus Real-Time Protection
set display_eng_start=0
set showballoon=1
set malware_message=1


:: Log scanned/detected files
set log_scanned=0
set log_detected=1
set stdout_log_scanned=0
set stdout_log_detected=1
set "logfile=%~dp0Batch-Antivirus_%date_%"

:: Engine scanning settings
set root_dir=%HomeDrive%\
set dir_scan_freq=20

:: Quarantine/delete (Not recommended to change)
set nodelete=0
set noquarantine=0

:: IP protection
set timeout_ip=2
set kill_process_ip=0
set balloon_notification_timeout=100000



::
::
::
:: End settings
cd /d "%~dp0"

if /i "%~1"=="--threads" set "threads=%~2" & for /l %%A in (1,1,%threads%) do (
	pause>nul
	start cmd.exe /c "%~f0"
)
if /i "%~1" neq "--ip" start /b cmd.exe /c "%~f0" --ip && goto scanip && exit /b
if /i "%~1"=="--fs" (
	if "%~2" neq "" set "rootdir=%~d2\"
)


if "%display_eng_start%"=="1" echo Batch Antivirus Real-Time Protection Engine started
timeout /t 1 /nobreak > nul
title %bav_rt_title%
:real_time
set counter=0
for /f "tokens=1* delims=:" %%A in ('WaitDirChange /ANY /s /f %root_dir% ^| findstr /i /c:"New_File" /c:"Mod_File" /c:"New_Name"') do (
	set /a counter+=1
	call :engine "%%~B"

	if %counter% geq %dir_scan_freq% for %%a in (*.*) do call :engine "/%%~a" 2> nul && set counter=0
)
goto real_time
pause>nul
exit /b


:engine

set "filescan=%~1"
set "filescan=!filescan:~1!"

if "%log_scanned%"=="1" echo.!filescan!>>"!logfile!"
if "%stdout_log_scanned%"=="1" echo.!filescan!
for /f %%A in ('sha256.exe "%filescan%" 2^>nul') do call :hashed %%A
exit /b


:hashed
set "hash=%~1"
set "hash=%hash:~1%"
findstr /c:"%hash%" "%~dp0VirusDataBaseHash.bav" > nul || exit /B
if "%stdout_log_detected%"=="1" echo.!filescan!
if "%log_detected%"=="1" echo.!filescan!>>!logfile!
for /f "tokens=1,2* delims=:" %%a in ('findstr /c:"%hash%" "%~dp0VirusDataBaseHash.bav"') do call :detection "%%~a" "%%~b"
goto :EOF

:detection
if "%~1" neq "%hash%" goto :EOF
echo on
call :getname "%filescan%"
taskkill /f /im "%filescan_basename%" > nul 2>&1
if "%showballoon%"=="1" start /b powershell [Reflection.Assembly]::LoadWithPartialName("""System.Windows.Forms""");$obj=New-Object Windows.Forms.NotifyIcon;$obj.Icon = [drawing.icon]::ExtractAssociatedIcon($PSHOME + """\powershell.exe""");$obj.Visible = $True;$obj.ShowBalloonTip(%balloon_notification_timeout%, """Batch Antivirus""","""Threats found: %~2""",2)>nul
if "%~1"=="%hash%" (echo Malware found: !filescan! ^| %~2) || goto :EOF
if "%noquarantine%"=="1" goto :EOF
md "%DIR%\Data\Quarantine\!hash!" 2>nul 1>nul
icacls "%filescan%" /setowner %username% 2>nul 1>nul
icacls "%filescan%" /grant %username%:(F,MA,WA,RA,WEA,REA,WDAC,DE) 2>nul 1>nul

move /y "%filescan%" "%DIR%\Data\Quarantine\%hash%\%hash%" 2>nul 1>nul
icacls "%DIR%\Data\Quarantine\%hash%\%hash%" /deny %username%:(RX,W,R,M,RD,WEA,REA,X,RA,WA) 2>nul 1>nul
set /a threats+=1
echo.%filescan%

if not exist "%filescan%" (if "%malware_message%"=="1" echo Malware successfully quarantined) else call :delete
echo off
goto :EOF

:delete
if "%nodelete%"=="1" goto :EOF

echo.
echo Failed to quarantine malware^^!
set /p "delmalware=Delete malware? (y/n): "
icacls "%filescan%" /setowner %username% 2>nul 1>nul
icacls "%filescan%" /grant %username%:(F,MA,WA,RA,WEA,REA,WDAC,DE) 2>nul 1>nul
if /i "%delmalware%"=="y" del !filescan! /s /q > nul

echo.
goto :EOF

:getname
set "filescan_basename=%~nx1"
exit /b

::netstat -no 2>&1 | findstr /i /c:"TCP" /c:"ESTABLISHED" | findstr /vc:"127.0.0.1"

:scanip
set ip=123.456.7.890
:: Fake IP
set old_ip=NULL
for /l %%A in () do (
	for /f "tokens=3,5 delims= " %%A in ('netstat -no 2^>^&1 ^| findstr /i /c:"TCP" /c:"ESTABLISHED"^| findstr /vc:"127.0.0.1"') do (
		set process_id=%%B
		for /f "tokens=1 delims=:" %%B in ("%%A") do set ip=%%C
		findstr /c:"!ip!" "%~dp0VirusDataBaseIP.bav" > nul 2>&1 && set "detected_ip=!ip!"&& call :malicious_ip "!ip!" && echo.Malicious IP: !ip!
		rem && echo Malicious website: !ip!
	)
	timeout /t %timeout_ip% /nobreak > nul 2>&1
)

goto scanip

:malicious_ip
if defined %ip:.=_% (
	if "%kill_process_ip%"=="1" taskkill /f /pid %process_id% > nul 2>&1 || echo Error while ending connection
	exit /b
)
set "%ip:.=_%=%ip%"
if "%showballoon%"=="1" start /b powershell [Reflection.Assembly]::LoadWithPartialName("""System.Windows.Forms""");$obj=New-Object Windows.Forms.NotifyIcon;$obj.Icon = [drawing.icon]::ExtractAssociatedIcon($PSHOME + """\powershell.exe""");$obj.Visible = $True;$obj.ShowBalloonTip(%balloon_notification_timeout%, """Batch Antivirus""","""Malicious IP connection: %ip%""",2)>nul && exit /b

exit /b
