::BAV_:git@github.com:anic17/Batch-Antivirus.git
@echo off
setlocal EnableDelayedExpansion
pushd "%~dp0\modules" > nul 2>&1|| goto badinstall
set /p bav_version=<"VirusDataBaseHash.bav"
set "bav_version=!bav_version::=!"
set bav_version=!bav_version!
title Batch Antivirus v!bav_version!
set admin=0
net session > nul 2>&1 && set admin=1

if not exist "%~dp0\modules\Data\FirstRun.ini" goto welcome

:menu
set already_admin=
if "!admin!"=="1" set already_admin= ^^^(already running as an adminstrator^^^)
cls
(
echo.Batch Antivirus v!bav_version!
echo.
echo.Modules:
echo.
echo.1^) Disk Scanner
echo.2^) Real-time Protection
echo.3^) Heuristical File Analyser
echo.4^) USB Malware Removal Tool
echo.5^) Website Blocker
echo.6^) Quarantine Viewer
echo.7^) Threat Information
echo.
echo.Tools:
echo.
echo.8^) Configure Batch Antivirus Autorun
echo.9^) Check for Updates
echo.
echo.Other:
echo.
echo.a^) Run this launcher as an administrator%already_admin%
echo.c^) Credits
echo.l^) Batch Antivirus v!bav_version! changelog 
echo.q^) Quit
echo.
) > con
<nul set /p "=Choice: "
choice /c:123456789aclq /n
echo.

if !errorlevel! geq 1 if !errorlevel! leq 9 goto :module_!errorlevel!
if !errorlevel! equ 10 goto runas
if !errorlevel! equ 11 goto credits
if !errorlevel! equ 12 goto changelog
if !errorlevel! equ 13 (
	popd
	exit /bv 0
)
goto menu
  

:module_1
echo.Starting disk scanner...
start cmd.exe /c "BAVDisk.bat"
timeout /t 1 > nul
goto menu

:module_2
echo.Starting Batch Antivirus real-time protection module...
start cmd.exe /c "RealTimeProtection.bat"
timeout /t 1 > nul
goto menu

:module_3
set /p "file=File to analyze: "
for /f "delims=" %%X in ("!file!") do set "file=%%~dpnxX"
call "DeepScan.bat" "!file!"
pause>nul
goto menu

:module_4
echo.Starting Batch Antivirus USB malware removal tool...
start cmd.exe /c "USBScan.bat"
goto menu

:module_5
echo.Starting Batch Antivirus website blocker...
start cmd.exe /c "BAVWebsiteBlocker.bat"
goto menu

:module_6
echo.Starting quarantine viewer...
start cmd.exe /c "Quarantine.bat"
timeout /t 1 > nul
goto menu

:module_7
echo.Starting Batch Antivirus threat information...
start cmd.exe /c "BAVDetail.bat"
timeout /t 1 > nul
goto menu

:module_8
echo.Starting Batch Antivirus autorun configuration module...
start cmd.exe /c "BAVAutorun.bat"
goto menu

:module_9
call "BAVUpdate.bat"
goto menu

:credits
echo.Batch Antivirus has been created by anic17
echo.If you want to use any component of Batch Antivirus, please link the repository and credit me.
echo.
echo.Official GitHub repository: https://github.com/anic17/Batch-Antivirus
echo.
echo.Special thanks to @BatchDebug for improving 'BAVIntercept.bat' module^^!
echo.Thanks @moongazer07, @MrDiamond64 and @timlg07 for the contributions.
echo.
echo.Copyright (c) 2025 anic17 Software
pause>nul
goto menu

:changelog
if not exist "%~dp0modules\Data\changelog.txt" (
	echo.Could not find the file '%~dp0modules\Data\changelog.txt'
	echo.
	echo.Press any key to return to the main menu...
	pause>nul
	goto menu
)
cls
more "%~dp0modules\Data\changelog.txt"
echo.Press any key to return to the main menu...
pause>nul
goto menu

:runas
:runas
powershell -ExecutionPolicy Bypass -Command Start-Process -Filepath """%comspec%""" -Args """/c call `""""%~0`"""" """ -verb RunAs
if "%errorlevel%" neq "0" (
	echo.Failed to start Batch Antivirus Launcher as an administrator
	echo.
	echo.Press any key to return to the main menu...
	pause>nul
	goto menu
)
exit /b


:welcome
(
echo.Thank you for trying out Batch Antivirus v!bav_version!^^!
echo.
echo.As it seems it is your first time using Batch Antivirus, here is a small explanation:
echo.
echo.Batch Antivirus is a project that started in June 2020 as a proof-of-concept antivirus
echo.written in batch. Its aim was to demonstrate the potential of the batch scripting
echo.language. Today, it can heuristically analyze files, detect hidden malware, block malicious
echo.websites, includes an auto-updater and even intercept malware before it is even ran.
echo.
echo.As of today, Batch Antivirus has databases consisting of 185k hashes, 314k IPs,
echo.8 malware-removal modules and other useful tools.
echo.
echo.Make sure to visit its webpage at https://anic17.github.io/Batch-Antivirus
echo.and support the project on the GitHub repository https://github.com/anic17/Batch-Antivirus
echo.
echo.Press any key to continue...
) > con
pause>nul
cls
echo.From this simple command-line user interface you will be able to start every Batch Antivirus
echo.module and tool.
echo.
echo.Batch Antivirus will now check that you're running the latest version to ensure the best
echo.system security.
call "BAVUpdate.bat"
<nul set /p "=FirstRun=0" > "%~dp0modules\Data\FirstRun.ini"

goto menu

:badinstall
echo.It seems like the Batch Antivirus installation was not successful.
echo.Please redownload Batch Antivirus from the official repository
echo.
echo.Press any key to open the repository...
pause>nul
start https://github.com/anic17/Batch-Antivirus
pause>nul
exit /b