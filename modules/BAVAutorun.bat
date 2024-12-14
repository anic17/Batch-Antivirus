::BAV_:git@github.com:anic17/Batch-Antivirus.git
@echo off
setlocal EnableDelayedExpansion
title Batch Antivirus Autorun Script
echo.Batch Antivirus Autorun Script.
echo.
pushd "%~dp0"
call "%~dp0BAVStatus.bat" --skip || exit /b
set found=0
echo Searching for autorun installations...
for %%# in ("HKCU" "HKLM") do (
	reg query "%%~#\Software\Microsoft\Windows\CurrentVersion\Run" /v "BAVAutoRun" > nul 2>&1 && (
		echo. - Found %%~# hive autorun
		set found=1
		set found_cvrun=1
		set found_%%~#=1
	)
)
for /f "tokens=2* delims= " %%A in ('reg query "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "Userinit"') do (
	set "regshell=%%B"
	set "regshell=!regshell:"=!"
	if "!regshell!" neq "!regshell:RealTimeProtection.bat --autorun-userinit=!" (echo. - Found shell autorun && set found=1 && set found_shell=1)
)
if "!found!"=="0" echo No Batch Antivirus autoruns found
echo.
echo.This script will install Batch Antivirus Real-Time background protection when the computer starts.
echo.It is highly recommended to run this script as an administrator.
echo.
echo.Are you sure you want to run Batch Antivirus every time your computer starts? (y/n)
choice /c:YN /n
if !errorlevel!==1 goto enable
if !errorlevel!==2 goto disable
echo.Unknown option
goto quit

:enable
echo.
echo.Autorun installation options:
echo. - Option 1: Current user (%username%)
echo. - Option 2: All users
echo. - Option 3: Shell (Recommended)
choice /c:123 /n
if errorlevel 1 set regpath=HKCU
if errorlevel 2 set regpath=HKLM
if errorlevel 3 goto shellenable

call :multiplefound shell
echo.Creating autorun...
reg add "!regpath!\Software\Microsoft\Windows\CurrentVersion\Run" /v "BAVAutoRun" /t REG_SZ /d "\"%~dp0RealTimeProtection.bat\"" /f > nul 2>&1 || (
	echo.Cannot write to the registry path. Try running this script as an administrator.
	goto quit
)
echo.Checking autorun installation...
reg query "!regpath!\Software\Microsoft\Windows\CurrentVersion\Run" /v "BAVAutoRun" > nul 2>&1 && (
	echo.Batch Antivirus autorun has been successfully created. You can disable it any time you want.
) || (
	echo.Failed to create autorun for Batch Antivirus^^!
)
goto quit

:disable
set /a found=0,deleted=0
for %%# in ("HKCU" "HKLM") do (
	echo.Checking %%~# registry hive...
	reg query "%%~#\software\Microsoft\Windows\CurrentVersion\Run" /v "BAVAutoRun" > nul 2>&1 && (
		echo.Found %%~# autorun: Removing...
		set /a found+=1
		reg delete "%%~#\Software\Microsoft\Windows\CurrentVersion\Run" /v "BAVAutoRun" /f > nul 2>&1 && (
			set /a deleted+=1
			echo.%%~# registry autorun deleted successfully. 
			echo.
		) || (
			echo.Failed to delete autorun on %%~# registry hive^^! 
			echo.
		)
	)
)
echo.Checking shell autorun...
for /f "tokens=2* delims= " %%A in ('reg query "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "Userinit"') do (
		set "regshell=%%B"
		set "regshell=!regshell:"=!"
		if "!regshell!" neq "!regshell:RealTimeProtection.bat --autorun-userinit=!" (
			echo.Found shell autorun: Removing...
			set /a found+=1
			reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "Userinit" /t REG_SZ /d "%SystemRoot%\System32\userinit.exe," /f > nul 2>&1 && (
				set /a deleted+=1
				echo.Shell autorun deleted successfully. 
				echo.
			) || (
				echo.Failed to delete shell autorun^^!
				echo.
			)
			
		)
	
)

echo.Deleted !deleted! out of !found! Batch Antivirus autoruns.
:quit
echo.
echo.Press any key to quit...
popd
pause>nul
endlocal
exit /b !errorlevel!

:shellenable
call :multiplefound cvrun
echo.Creating shell autorun...

set "install_dir=%~dp0"
echo.!install_dir! | findstr /bic:"!userprofile!" > nul 2>&1 && (
	echo.Could not create Batch Antivirus Autorun because it is currently installed on a user directory.
	echo.
	echo.Please move this installation to a non-user path ^(e.g. '!ProgramFiles!' or '!HomeDrive!\Batch Antivirus'^)
	goto quit
)


reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "Userinit" /t REG_SZ /d "\"%~dp0RealTimeProtection.bat\" --autorun-userinit" /f > nul 2>&1 || (
	echo.Cannot write to the registry path. Try running this script as an administrator.
	goto quit
)
echo.Checking autorun shell installation...
reg query "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "Userinit" > nul 2>&1 && (
	echo.Batch Antivirus shell autorun has been successfully created. You can disable it any time you want.
) || (
	echo.Failed to create autorun for Batch Antivirus^^!
)
goto quit

:multiplefound <found_>
if "!found_%~1!"=="1" (
	echo.
	echo.Creating more than one autorun for Batch Antivirus is strongly discouraged.
	echo.Do you still wish to proceed? ^(y/n^)
	choice /c:YN /n
	if "!errorlevel!" neq "1" goto quit
)
exit /b