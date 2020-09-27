@echo off
setlocal EnableDelayedExpansion

if "%~1" neq "--ip" start /b cmd.exe /c "%~f0" --ip && goto scanip && exit /b
cd /d "%~dp0"
md "%~dp0Data\Quarantine" > nul 2>&1
set dir=%CD%
set root_dir=C:\

tasklist /fi "windowtitle eq Batch Antivirus Real-Time Protection" > nul 2>&1 && echo started || echo ok

::&& echo.An instance of Batch Antivirus already started. && pause>nul && exit /b %errorlevel%
echo Batch Antivirus Real-Time Protection Engine started
timeout /t 1 /nobreak > nul
title Batch Antivirus Real-Time Protection
:real_time
set counter=0
for /f "tokens=1* delims=:" %%A in ('WaitDirChange /ANY /s /f %root_dir% ^| findstr /i /c:"New_File" /c:"Mod_File" /c:"New_Name"') do (
	set /a counter+=1
	call :engine "%%~B"
	echo."%%~B">>"%CD%\scanned_.txt"
	if %counter% geq 20 for %%a in (*.*) do call :engine "/%%~a" 2> nul && set counter=0
)
goto real_time
pause>nul
exit /b


:engine

set "filescan=%~1"
set "filescan=!filescan:~1!"
echo.!filescan!
for /f %%A in ('sha256.exe "%filescan%" 2^>nul') do call :hashed %%A
exit /b


:hashed
set "hash=%~1"
set "hash=%hash:~1%"
findstr /c:"%hash%" "%~dp0VirusDataBaseHash.bav" > nul || exit /B

for /f "tokens=1,2* delims=:" %%a in ('findstr /c:"%hash%" "%~dp0VirusDataBaseHash.bav"') do call :detection "%%~a" "%%~b"
goto :EOF

:detection
if "%~1" neq "%hash%" goto :EOF

call :getname "%filescan%"
taskkill /f /im "%filescan_basename%" > nul 2>&1
start /b powershell [Reflection.Assembly]::LoadWithPartialName("""System.Windows.Forms""");$obj=New-Object Windows.Forms.NotifyIcon;$obj.Icon = [drawing.icon]::ExtractAssociatedIcon($PSHOME + """\powershell.exe""");$obj.Visible = $True;$obj.ShowBalloonTip(100000, """Batch Antivirus""","""Threats found: %~2""",2)>nul
if "%~1"=="%hash%" (echo Malware found: !filescan! ^| %~2) || goto :EOF
md "%DIR%\Data\Quarantine\!hash!" 2>nul 1>nul
icacls "%filescan%" /setowner %username% 2>nul 1>nul
icacls "%filescan%" /grant %username%:(F,MA,WA,RA,WEA,REA,WDAC,DE) 2>nul 1>nul

move /y "%filescan%" "%DIR%\Data\Quarantine\%hash%\%hash%" 2>nul 1>nul
icacls "%DIR%\Data\Quarantine\%hash%\%hash%" /deny %username%:(RX,W,R,M,RD,WEA,REA,X,RA,WA) 2>nul 1>nul
set /a threats+=1
echo.%filescan%

if not exist "%filescan%" (echo Malware successfully quarantined) else call :delete

goto :EOF

:delete


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
	timeout /t 2 /nobreak > nul 2>&1
)

goto scanip

:malicious_ip
if defined %ip:.=_% (
	taskkill /f /pid %process_id% > nul 2>&1 || echo Error while ending connection
	exit /b
)
set "%ip:.=_%=%ip%"
start /b powershell [Reflection.Assembly]::LoadWithPartialName("""System.Windows.Forms""");$obj=New-Object Windows.Forms.NotifyIcon;$obj.Icon = [drawing.icon]::ExtractAssociatedIcon($PSHOME + """\powershell.exe""");$obj.Visible = $True;$obj.ShowBalloonTip(100000, """Batch Antivirus""","""Malicious IP connection: %ip%""",2)>nul && exit /b

exit /b
