::BAV_:git@github.com:anic17/Batch-Antivirus.git
@echo off
setlocal EnableDelayedExpansion
title Batch Antivirus autorun script
echo.Batch Antivirus autorun script.
echo.
<nul set /p "=Checking Batch Antivirus file integrity... "
for %%A in (
	"%~dp0BAV.bat"
	"%~dp0BAVDetail.bat"
	"%~dp0DeepScan.bat"
	"%~dp0InstallIntercept.bat"
	"%~dp0Quarantine.bat"
	"%~dp0RealTimeProtection.bat"
	"%~dp0ScanIntercept.bat"
	"%~dp0USBCleaner.bat"
	"%~dp0USBScan.bat"
	"%~dp0VirusDataBaseHash.bav"
	"%~dp0VirusDataBaseIP.bav"
	"%~dp0gethex.exe"
	"%~dp0sha256.exe"
	"%~dp0waitdirchange.exe"
) do (
	if not exist "%%~A" (
		echo.
		echo.Corrupt Batch Antivirus installation. Please redownload it from the official GitHub.
		echo.https://github.com/anic17/Batch-Antivirus
		pause>nul
		endlocal
		exit /b !errorlevel!
	)
)
echo.done
echo.Searching for autorun installations...
for %%# in ("HKCU" "HKLM") do (
	reg query "%%~#\Software\Microsoft\Windows\CurrentVersion\Run" /v "BAVAutoRun" > nul 2>&1 && echo. - Found %%~# hive
)
for /f "tokens=2* delims= " %%A in ('reg query "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "Userinit"') do (
		set "regshell=%%B"
		set "regshell=!regshell:"=!"
		if "!regshell!"=="%~dp0RealTimeProtection.bat --autorun-userinit" echo. - Found shell autorun
	
)
echo.
echo.This script will install Batch Antivirus real time protection when the computer starts.
echo.It is highly recommended to run this script as an administrator.
echo.
echo.However, you shouldn't install more than 1 single autorun on the PC.
echo.
echo.Are you sure you want to run Batch Antivirus every time your computer starts? (y/n)
choice /c:YN /n > nul
if !errorlevel!==1 goto enable
if !errorlevel!==2 goto disable
echo.Unknown option
goto exit

:enable
echo.
echo.Autorun installation options:
echo. - Option 1: Current user (%username%)
echo. - Option 2: All users
echo. - Option 3: Shell (Recommended)
choice /c:123 /n >nul
if errorlevel 1 set regpath=HKCU
if errorlevel 2 set regpath=HKLM
if errorlevel 3 goto shellenable
echo.Installing autorun...
reg add "!regpath!\Software\Microsoft\Windows\CurrentVersion\Run" /v "BAVAutoRun" /t REG_SZ /d "\"%~dp0RealTimeProtection.bat\"" /f > nul 2>&1 || (
	echo.Cannot write to the registry path. Try running this script with administrator privileges.
	goto quit
)
echo.Checking autorun installation...
reg query "!regpath!\Software\Microsoft\Windows\CurrentVersion\Run" /v "BAVAutoRun" > nul 2>&1 && (
	echo.Batch Antivirus autorun has been successfully installed. You can disable it any time you want.
) || (
	echo.Failed to install autorun for Batch Antivirus^^!
)
echo.
goto quit

:disable
set /a found=0,deleted=0
for %%# in ("HKCU" "HKLM") do (
	echo.Checking %%~# registry hive...
	reg query "%%~#\software\Microsoft\Windows\CurrentVersion\Run" /v "BAVAutoRun" > nul 2>&1 && (
		echo.Found autorun on %%~#: Removing...
		set /a found+=1
		reg delete "%%~#\Software\Microsoft\Windows\CurrentVersion\Run" /v "BAVAutoRun" /f > nul 2>&1 && (
			set /a deleted+=1
			echo.%%~# registry autorun deleted successfully. 
			echo.
		) || (
			echo.Failed to delete autorun on %%~# registry hive^^! 
		)
	)
)
echo.Checking shell autorun...
for /f "tokens=2* delims= " %%A in ('reg query "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "Userinit"') do (
		set "regshell=%%B"
		set "regshell=!regshell:"=!"
		if "!regshell!"=="%~dp0RealTimeProtection.bat --autorun-userinit" (
			echo.Found shell autorun: Removing...
			set /a found+=1
			reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "Userinit" /t REG_SZ /d "%SystemRoot%\System32\userinit.exe," /f > nul 2>&1 && (
				set /a deleted+=1
				echo.Shell autorun deleted successfully. 
				echo.
			) || (
				echo.Failed to delete shell autorun^^! 
			)
			
		)
	
)

echo.Deleted !deleted! out of !found! Batch Antivirus autoruns.
echo.
:quit
echo.Press any key to quit...
pause>nul
endlocal
exit /b !errorlevel!

:shellenable
echo.Installing shell autorun...
reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "Userinit" /t REG_SZ /d "\"%~dp0RealTimeProtection.bat\" --autorun-userinit" /f > nul 2>&1 || (
	echo.Cannot write to the registry path. Try running this script with administrator privileges.
	goto quit
)
echo.Checking autorun shell installation...
reg query "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "Userinit" > nul 2>&1 && (
	echo.Batch Antivirus shell autorun has been successfully installed. You can disable it any time you want.
) || (
	echo.Failed to install autorun for Batch Antivirus^^!
)
echo.
goto quit