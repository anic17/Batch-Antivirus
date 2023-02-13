::BAV_:git@github.com:anic17/Batch-Antivirus.git
@echo off
for %%A in ("--help" "/?" "-?" "-h" "-help" "/help" "/h") do if /i "%~1"=="%%~A" (
	echo.
	echo.Batch Antivirus - Real-Time Protection
	echo.
	echo.Usage:
	echo.
	echo.Syntax:
	echo.RealTimeProtection [--ip ^| --pc-monitor ^| --drive ^<drive^>]
	echo.
	echo.Examples:
	echo.
	echo.RealTimeProtection --ip
	echo.IP protection: Detect and kill any process communicating with a malicious IP.
	echo.
	echo.RealTimeProtection --pc-monitor
	echo.Starts PC monitor, which checks for the disk space left and CPU temperature and alerts
	echo.the user when one of them exceeds the healthy limits for the PC.
	echo.
	echo.RealTimeProtection --kill-protection
	echo.Enables kill protection: If the real-time protection gets killed, the process gets
	echo.relaunched to protect again the computer.
	echo.
	echo.RealTimeProtection --drive F:\
	echo.Will monitor drive F:
	echo.
	echo.Copyright ^(c^) 2023 anic17 Software
	exit /b
)

call "%~dp0BAVStatus.bat" --skip || exit /b
call "%~dp0BAVConfig.bat"

if not defined runningInBackground set runningInBackground=0
if "%~1"=="--autorun-userinit" set runningInBackground=1
setlocal EnableDelayedExpansion

md "%~dp0Data\Quarantine" > nul 2>&1
set "dir=!CD!"

if "%~1"=="--kill-protection" (
	set "kill_protection=1"
	for /l %%A in () do (
		if not exist "!tmp!\!kp_file!" (
			call :killprot
		)
		timeout /t 1 /nobreak > nul
	)
)
if exist "!TMP!\BAV_RTP_.tmp" if "%~1"=="" (
	if "!kill_protection!"=="1" (
		(tasklist /fi "imagename eq !chkss_pth!" | findstr /c:"=" > nul 2>&1 ) || goto no_instance_running
	)
	for /f "tokens=2,9 delims=," %%A in ('tasklist /fi "imagename eq cmd.exe" /v /fo:csv ^| findstr /c:"cmd.exe"') do (
		if "%%~B"=="!bav_rt_title!" (
			echo.An instance of Batch Antivirus Real-Time Protection in background is already running ^(PID %%~A^)
			goto quit
		) else (
			del "!TMP!\BAV_RTP_.tmp" /q /f > nul 2>&1
		)
	)
)
:no_instance_running
if /i "%~1"=="--autorun-userinit" (
	rem Start Batch Antivirus as a background process
	(tasklist /fi "imagename eq explorer.exe" | findstr /c:"=" > nul 2>&1) && (
		echo.Cannot use '--autorun-userinit': explorer.exe is already started
	) || (
	
	echo.Set objFSO=CreateObject^("Scripting.FileSystemObject"^)> "!TMP!\bav_hidden.vbs"
	echo.BAVRTPFile="!TMP!\BAV_RTP_.tmp" >> "!TMP!\bav_hidden.vbs"
	echo.Set objFile = objFSO.CreateTextFile^(BAVRTPFile,True^) >> "!TMP!\bav_hidden.vbs"
	echo.createObject^(^"WScript.Shell^"^).Run ^"cmd.exe /c ^"^"%~f0^"^"^", vbHide, true >> "!TMP!\bav_hidden.vbs"
	echo.If objFSO.FileExists^(BAVRTPFile^) Then >> "!TMP!\bav_hidden.vbs"
	echo.     objFSO.DeleteFile^(BAVRTPFile^) >> "!TMP!\bav_hidden.vbs"
	echo.End if >> "!TMP!\bav_hidden.vbs"

		
	start wscript.exe "!TMP!\bav_hidden.vbs"
	rem As the shell got overwritten, run the userinit process
	start "" "!SystemRoot!\System32\userinit.exe"
	)
	exit /b
)

call :killprot
cd /d "%~dp0"
if "%~1"=="--ip" goto scanip
if "%~1"=="--pc-monitor" goto pcmonitor
if "%~1"=="" (
	call "%~dp0BAVUpdate.bat" --skip
	start /b cmd.exe /c "%~f0" --ip
	start /b cmd.exe /c "%~f0" --pc-monitor
)



if "!kill_protection!"=="1" start /b cmd.exe /c "%~f0" --kill-protection


if /i "%~1"=="--drive" (
	if "%~2" neq "" set "rootdir=%~d2\"
)

if "!display_eng_start!"=="1" echo Batch Antivirus Real-Time Protection Engine started
title !bav_rt_title!
:real_time
set counter=0
for /f "tokens=1* delims=:" %%A in ('WaitDirChange /ANY /s /f !root_dir!') do (
	set /a counter+=1
	if "%%~A" neq "WaitDirChg" call :engine "%%~B"


	if !counter! geq !dir_scan_freq! (
		call :engine "%%~A" "--dir" "%%~dpA"
		set counter=0
	)
)

goto real_time

:engine
set "filescan=%~1"
for /f "usebackq tokens=*" %%X in (`echo.!filescan!`) do set "filescan=%%X"
if "%~2"=="--dir" (
	set "scandir=%~3" 
	for /f "tokens=1 delims= " %%A in ('sha256.exe "!scandir!\*.*" 2^>nul') do (
		call :hashed "%%~A"
	)
) else (
	for /f "tokens=1 delims= " %%A in ('sha256.exe "!filescan!" 2^>nul') do call :hashed "%%~A"
)
exit /b


:hashed
if "%~1"=="" exit /b

set "hash=%~1"
set "hash=!hash:\=!"
for /f "tokens=1* delims=:" %%A in ('findstr /bc:"!hash!" "%~dp0VirusDataBaseHash.bav"') do (
	call :detection "!hash!" "%%~B"
)
exit /b

:detection
if "%~2"=="" exit /b
if "!log_detected!"=="1" echo.!filescan! >> "!logfile!"

for /f "delims=" %%A in ("!filescan!") do set "filescan_basename=%%~nxA"
taskkill /f /im "!filescan_basename!" > nul 2>&1
call :balloon "Threats found: %~2" "Batch Antivirus" Warning
echo Malware found: "!filescan!" ^(!hash!^) ^| %~2
if "%noquarantine%"=="1" goto :EOF
md "%~dp0Data\Quarantine\!hash!" > nul 2>&1
icacls "!filescan!" /setowner "!username!" > nul 2>&1
icacls "!filescan!" /grant "!username!":(F,MA,WA,RA,WEA,REA,WDAC,DE) > nul 2>&1

del "%~dp0Data\Quarantine\!hash!\!hash!" /q /f > nul 2>&1
move /y "!filescan!" "%~dp0Data\Quarantine\!hash!\!hash!.tmp" > nul 2>&1
certutil -encode "%~dp0Data\Quarantine\!hash!\!hash!.tmp" "%~dp0Data\Quarantine\!hash!\!hash!" > nul 2>&1 && del "%~dp0Data\Quarantine\!hash!\!hash!.tmp" /q /f > nul 2>&1
for /f "delims=" %%A in ("!filescan!") do echo.%%~fA >> "%~dp0\Data\Quarantine\!hash!\name"
echo.%~2 > "%~dp0\Data\Quarantine\!hash!\detection"
icacls "%~dp0Data\Quarantine\!hash!\!hash!" /deny "!username!":(RX,W,R,M,RD,WEA,REA,X,RA,WA) > nul 2>&1
set /a threats+=1

if not exist "!filescan!" (
	if "%malware_message%"=="1" echo Malware successfully quarantined.
) else (
	call :delete
)

:: Scan all files inside the detected directory
for /f "delims=" %%# in ("!filescan!") do (
	call :engine "!filescan!" --dir "%%~#"
) 
goto :EOF

:delete
if "%nodelete%"=="1" goto :EOF

echo.
echo Failed to quarantine malware^^!
choice /c:YN /n
if !errorlevel!==1 (
	icacls "!filescan!" /setowner "!username!" > nul 2>&1
	icacls "!filescan!" /grant "!username!":(F,MA,WA,RA,WEA,REA,WDAC,DE) > nul 2>&1
	del "!filescan!" /q /f > nul 2>&1 && (
		echo.Successfully deleted the malware.
	) else (
		echo.Failed to delete the malware^^!
	)
)
echo.
goto :EOF

:scanip
set ip=

for /f "tokens=2,3 delims=:" %%A in ('netstat -no ^| findstr /vc:"127.0.0.1"') do (
	for /f "tokens=2 delims= " %%X in ("%%A") do (
		set "ip=%%X"
	)
	for /f "tokens=3 delims= " %%# in ("%%B") do (
		set "process_id=%%#"
	)
	findstr /bc:"!ip!" "%~dp0VirusDataBaseIP.bav" > nul 2>&1 && (
		call :malicious_ip "!ip!" "!process_id!"
	)
)
timeout /t !timeout_ip! /nobreak > nul 2>&1


goto scanip

:malicious_ip <ip> <pid>
for /f "tokens=1 delims= " %%B in ('tasklist /fi "pid eq %~2" ^| findstr /c:"%~2"') do (
	if !errorlevel! neq 0 (
		echo.Error while getting process name for '%~2' PID
	) else (
		set "malicious_ip_process=%%B"
	)
)

if "!malicious_ip_old!" neq "%~1" if "!malicious_pid_old!" neq "%~2" (
	if "%runningInBackground%"=="1" (
		call :balloon "Malicious IP connection: %~1^___^&vbCrLf^&___Process: !malicious_ip_process!^___^&vbCrLf^&___PID: %~2" "Batch Antivirus" Warning
	) else (
		call :balloon "Malicious IP connection: %~1`nProcess !malicious_ip_process!`nPID: %~2" "Batch Antivirus" Warning
	)
)
if "%kill_process_ip%"=="1" taskkill /f /pid %~2 > nul 2>&1 || echo Error while ending connection


echo.Malicious IP connection: %~1
echo.Process name: !malicious_ip_process!
echo.PID: %~2
echo.
set "malicious_ip_old=%~1"
set "malicious_pid_old=%~2"
exit /b

:balloon <text> <title> <icontype>

if "%runningInBackground%"=="1" (
	set icontype=4144
	if /i "%~3"=="Error" set "icontype=4112"
	if /i "%~3"=="Question" set "icontype=4128"
	if /i "%~3"=="Warning" set "icontype=4144"
	if /i "%~3"=="Info" set "icontype=4160"
	set "text=%~1"
	set "text=!text:___="!"
	echo.bav=msgbox^("!text!", !icontype!, "%~2"^) >"!TMP!\bav_msgbox.vbs"
	echo.createObject^(^"WScript.Shell^"^).Run "wscript.exe //nologo ""!TMP!\bav_msgbox.vbs""", 1 > "!TMP!\bav_fg.vbs"
	start wscript.exe //nologo "!TMP!\bav_fg.vbs"
	exit /b
)


if "%showballoon%"=="1" if "%runningInBackground%" neq "1" start /b powershell [Reflection.Assembly]::LoadWithPartialName("""System.Windows.Forms""");$obj=New-Object Windows.Forms.NotifyIcon;$obj.Icon = [System.Drawing.SystemIcons]::%~3; $obj.BalloonTipIcon = """%~3""";$obj.Visible = $True;$obj.ShowBalloonTip(%balloon_notification_timeout%, """%~2""","""%~1""",2) > nul

exit /b

:pcmonitor
set display_overheat=1
set display_lowdisk=1
:pcmonitor_loop
for /f %%A in ('wmic /namespace:\\root\cimv2 path Win32_PerfFormattedData_Counters_ThermalZoneInformation get Temperature  2^>nul ^| findstr /rc:"[0-9]"') do (
	set /a temperature=%%A-273
	if !temperature! geq 90 if !display_overheat! equ 1 (
		echo.WARNING: CPU overheat ^(!temperature!C^). It is recommended to power off the computer.
		call :balloon "WARNING: CPU overheat ^(!temperature!C^). It is recommended to power off the computer." "Batch Antivirus" Warning
		set display_overheat=0
		
	)
	
)

if "!display_lowdisk!"=="1" (
	for /f "usebackq tokens=1,2 delims=$" %%A in (`powershell -ExecutionPolicy Bypass -Command "Get-PSDrive ($env:systemdrive).Substring(0,1)| %% { if($_.free -ge 10GB){$unitdivide = 1GB;$letter='G'} else {$unitdivide = 1MB;$letter='M'};if($_.Used){$freepercent = 100*$_.Free / ($_.Used + $_.Free);if($freepercent -le 5){Write-Output ('Less than ' + [math]::Round($freepercent) + '%%%% free space left on drive ' + $_.Root + ' (' + ([math]::Round($_.Free/$unitdivide, 1)) + $letter +'B)$1'); exit 1} else {Write-Output ' $0'; exit 0}}}"`) do (
		set "result_lowdisk=%%A"
		set "retcode_lowdisk=%%B"
	)
	if "!retcode_lowdisk!"=="1" (
		set "display_lowdisk=0"
		call :balloon "!result_lowdisk!" "Batch Antivirus" Warning
	)
)
timeout /t 60 /nobreak > nul
goto pcmonitor_loop


:killprot
if "!kill_protection!"=="1" (
	del "!TMP!\!kp_file!" /q > nul 2>&1
	del "!TMP!\sec_kp_*" /q > nul 2>&1
	copy /y "%~dp0sha256.exe" "!TMP!\!chkss_pth!" >nul 2>&1
	start /b "" "!TMP!\!chkss_pth!" > nul 2>&1
	echo On Error Resume Next > "!TMP!\!kp_file!"
	echo Set BAVkpWMIe = GetObject^(^"winmgmts:^" _ >> "!TMP!\!kp_file!"
	echo     ^& "{impersonationLevel=impersonate}!^\^\" ^& "." ^& "^\root^\cimv2"^) >> "!TMP!\!kp_file!"
	echo.createObject^(^"WScript.Shell^"^).Run ^"cmd /c ""%~f0""", vbHide, 1 >> "!TMP!\!kp_file!"
	echo do >> "!TMP!\!kp_file!"
	echo Set kpProcList= BAVkpWMIe.ExecQuery _ >> "!TMP!\!kp_file!"
	echo     ^(^"Select * from Win32_Process Where Name = ^'!chkss_pth!^'^"^) >> "!TMP!\!kp_file!"
	echo If kpProcList.count ^< 1 then >> "!TMP!\!kp_file!"
	echo.		createObject^(^"WScript.Shell^"^).Run ^"^"^"%~f0 %*^"^"^" >> "!TMP!\!kp_file!"
	echo 		MsgBox "Batch Antivirus process got killed", 4112, "Batch Antivirus" >> "!TMP!\!kp_file!"
	echo.		WScript.Quit^(^) >> "!TMP!\!kp_file!"
	echo End If >> "!TMP!\!kp_file!"
	echo WScript.Sleep^(300^) >> "!TMP!\!kp_file!"
	echo loop >> "!TMP!\!kp_file!"
	start /min cmd.exe /c start "" wscript.exe //nologo "!TMP!\!kp_file!"
	timeout /t 1 /nobreak > nul
)
goto :EOF

:quit
echo.
echo.Press any key to quit..
pause>nul
endlocal
exit /b