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

for %%A in (
"%~dp0VirusDataBaseHash.bav"
"%~dp0gethex.exe"
"%~dp0sha256.exe"
"%~dp0VirusDatabaseIP.bav"
"%~dp0waitdirchange.exe"
"%~dp0checkdiff.exe"
) do (
	if not exist "%%~A" (
		echo.Engine cannot start^!
		echo.Missing file: "%%~A"
		exit /b
	)
)

if not defined threads set threads=1
setlocal EnableDelayedExpansion

md "%~dp0Data\Quarantine" > nul 2>&1
set "dir=%CD%"


for /f "tokens=1-3 delims=/" %%A in ('date /t') do set "date_=%%A%%B%%C"
set "date_=!date_:-=!"
::Start settings
::
:: Don't mess up with settings, it might leave your system unprotected
::
::

:: Graphical settings
set bav_rt_title=Batch Antivirus Real-Time Protection
set display_eng_start=1
set display_title=1
set showballoon=1
set malware_message=1
set balloon_notification_timeout=100000

set background_process=1


:: Log scanned/detected files
set log_scanned=0
set log_detected=1
set stdout_log_scanned=0
set stdout_log_detected=1
set "logfile="%~dp0Batch-Antivirus_!date_!""	

:: Engine scanning settings
set root_dir=%HomeDrive%\
set dir_scan_freq=3

:: Quarantine/delete (Not recommended to change)
set nodelete=0
set noquarantine=0

:: IP protection
set timeout_ip=2
set kill_process_ip=0

:: Engine protection
set kill_protection=0
set "kp_file=BAV_kp.vbs"

set "chkss_pth=sec_kp_%random:~-3%%random:~-3%_bav.tmp%random:~-2%"





::
::
::
:: End settings
cd /d "%~dp0"

if "!kill_protection!"=="1" (
	del "%TMP%\!kp_file!" /q > nul 2>&1
	del "%TMP%\sec_kp_*" /q > nul 2>&1
	copy /y "%~dp0sha256.exe" "%tmp%\!chkss_pth!" >nul 2>&1
	start /b "" "%tmp%\!chkss_pth!" > nul 2>&1
	echo On Error Resume Next > "%TMP%\!kp_file!"
	echo Set BAVkpWMIe = GetObject^(^"winmgmts:^" _ >> "%TMP%\!kp_file!"
	echo     ^& "{impersonationLevel=impersonate}!^\^\" ^& "." ^& "^\root^\cimv2"^) >> "%TMP%\!kp_file!"
	rem echo.createObject^(^"WScript.Shell^"^).Run ^"cmd /c start /b ^"^"^"^" ^"^"%tmp%\!chkss_pth!^"^"^", vbHide, 1 >> "%TMP%\!kp_file!"
	echo do >> "%TMP%\!kp_file!"
	echo Set kpProcList= BAVkpWMIe.ExecQuery _ >> "%TMP%\!kp_file!"
	echo     ^(^"Select * from Win32_Process Where Name = ^'!chkss_pth!^'^"^) >> "%TMP%\!kp_file!"
	echo If kpProcList.count ^< 1 then >> "%TMP%\!kp_file!"
	echo 		MsgBox "Batch Antivirus process got killed", 4112, "Batch Antivirus" >> "%TMP%\!kp_file!"
	echo.		WScript.Quit^(^) >> "%TMP%\!kp_file!"
	echo End If >> "%TMP%\!kp_file!"
	echo WScript.Sleep^(300^) >> "%TMP%\!kp_file!"
	echo loop >> "%TMP%\!kp_file!"
	start /min cmd.exe /c start "" wscript.exe //nologo "%TMP%\!kp_file!"
	timeout /t 1 /nobreak > nul
)

if /i "%~1"=="--threads" set "threads=%~2" & for /l %%A in (2,1,!threads!) do (
	timeout /t 1 /nobreak > nul
	start /b cmd.exe /c "%~f0"
)

::if "%~1"=="" (
::	start /b cmd.exe /c "%~f0" --ip
::	rem start /b cmd.exe /c "%~f0" --svc
::)
::if "%~1"=="--svc" goto scanservices
if "%~1"=="--ip" goto scanip


if /i "%~1"=="--fs" (
	if "%~2" neq "" set "rootdir=%~d2\"
)

if "%display_eng_start%"=="1" echo Batch Antivirus Real-Time Protection Engine started
if "%display_title%"=="1" title %bav_rt_title%
:real_time
set counter=0
for /f "tokens=1* delims=:" %%A in ('WaitDirChange /ANY /s /f %root_dir% ^| findstr /i /c:"New_File" /c:"Mod_File" /c:"New_Name"') do (
	set /a counter+=1
	call :engine "%%~B"

	if !counter! geq !dir_scan_freq! for %%a in (*.*) do call :engine "/%%~a" 2> nul && set counter=0
)
goto real_time
pause>nul
exit /b


:engine
set "filescan=%~1"
set "filescan=!filescan:~1!"

if "%log_scanned%"=="1" echo.!filescan! >>"!logfile!"
if "%stdout_log_scanned%"=="1" echo.!filescan!
for /f %%A in ('sha256.exe "%filescan%" 2^>nul') do call :hashed %%A
exit /b


:hashed

set "hash=%~1"
set "hash=%hash:~1%"
findstr /c:"%hash%" "%~dp0VirusDataBaseHash.bav" > nul || exit /B
if "%stdout_log_detected%"=="1" echo.!filescan!
if "%log_detected%"=="1" echo.!filescan! >> "!logfile!"
for /f "tokens=1,2* delims=:" %%a in ('findstr /c:"%hash%" "%~dp0VirusDataBaseHash.bav"') do call :detection "%%~a" "%%~b"
goto :EOF

:detection
if "%~1" neq "%hash%" goto :EOF
call :getname "%filescan%"
taskkill /f /im "%filescan_basename%" > nul 2>&1
if "%showballoon%"=="1" start /b powershell [Reflection.Assembly]::LoadWithPartialName("""System.Windows.Forms""");$obj=New-Object Windows.Forms.NotifyIcon;$obj.Icon = [drawing.icon]::ExtractAssociatedIcon($PSHOME + """\powershell.exe""");$obj.Visible = $True;$obj.ShowBalloonTip(%balloon_notification_timeout%, """Batch Antivirus""","""Threats found: %~2""",2)>nul
if "%~1"=="%hash%" (echo Malware found: !filescan! ^(!hash!^) ^| %~2) || goto :EOF
if "%noquarantine%"=="1" goto :EOF
md "%DIR%\Data\Quarantine\!hash!" 2>nul 1>nul
icacls "%filescan%" /setowner %username% 2>nul 1>nul
icacls "%filescan%" /grant %username%:(F,MA,WA,RA,WEA,REA,WDAC,DE) 2>nul 1>nul

move /y "%filescan%" "%DIR%\Data\Quarantine\%hash%\%hash%" 2>nul 1>nul
for /f "delims=" %%A in ("!filescan!") do echo.%%~fA >> "%DIR%\Data\Quarantine\%hash%\name"
icacls "%DIR%\Data\Quarantine\%hash%\%hash%" /deny %username%:(RX,W,R,M,RD,WEA,REA,X,RA,WA) 2>nul 1>nul
set /a threats+=1
echo.%filescan%

if not exist "%filescan%" (if "%malware_message%"=="1" echo Malware successfully quarantined) else call :delete

goto :EOF

:delete
if "%nodelete%"=="1" goto :EOF

echo.
echo Failed to quarantine malware^^!
set /p "delmalware=Delete malware? (y/n): "
icacls "%filescan%" /setowner %username% 2>nul 1>nul
icacls "%filescan%" /grant %username%:(F,MA,WA,RA,WEA,REA,WDAC,DE) 2>nul 1>nul
if /i "%delmalware%"=="y" del !filescan! /s /q > nul 2>&1

echo.
goto :EOF

:getname
set "filescan_basename=%~nx1"
exit /b

::netstat -no 2>&1 | findstr /i /c:"TCP" /c:"ESTABLISHED" | findstr /vc:"127.0.0.1"
:scanservices
timeout /t 2 /nobreak > nul
reg query HKLM\SYSTEM\CurrentControlSet\Services > "%TMP%\batch_antivirus_servicelist.tmp"
timeout /t 2 /nobreak>nul
reg query HKLM\SYSTEM\CurrentControlSet\Services > "%TMP%\batch_antivirus_servicelist2.tmp"


checkdiff "%TMP%\batch_antivirus_servicelist.tmp" "%TMP%\batch_antivirus_servicelist2.tmp"

for /f "usebackq delims=" %%A in ("%TMP%\batch_antivirus_scan_services.tmp") do (
	for /f "delims=" %%B in ('reg query "HKLM\SYSTEM\CurrentControlSet\Services\%%~A" ^| Findstr /ic:"ImagePath"') do call :engine "_%%~A"
)
goto scanservices


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
for /f "tokens=1 delims= " %%B in ('tasklist /fi "pid eq %process_id%" ^| findstr /c:"%process_id%"') do (
	if !errorlevel! neq 0 (
		echo.Error while getting process name for '%process_id%' PID
	) else (
		set "malicious_ip_process=%%B"
if defined %ip:.=_% (
	if "%kill_process_ip%"=="1" taskkill /f /pid %process_id% > nul 2>&1 || echo Error while ending connection
	exit /b
)
set "%ip:.=_%=%ip%"
if "%showballoon%"=="1" start /b powershell [Reflection.Assembly]::LoadWithPartialName("""System.Windows.Forms""");$obj=New-Object Windows.Forms.NotifyIcon;$obj.Icon = [drawing.icon]::ExtractAssociatedIcon($PSHOME + """\powershell.exe""");$obj.Visible = $True;$obj.ShowBalloonTip(%balloon_notification_timeout%, """Batch Antivirus""","""Malicious IP connection: %ip%`nProcess `"%malicious_ip_process%`"""",2)>nul && exit /b

exit /b

:
rem findstr /ic:"free iphone." /c:"visitor 1,000,000" /c:"visitor 1,000" /c:"visitor 999,999" /c:"Malware found" /c:"Virus detected" /c:"888-795-1528" /c:"
rem %localappdata%\Packages\microsoft.windowscommunicationsapps_8wekyb3d8bbwe\LocalState\Files\S0\4\Attachments