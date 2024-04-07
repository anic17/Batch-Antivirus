::BAV_:git@github.com:anic17/Batch-Antivirus.git
@echo off
setlocal EnableDelayedExpansion

if /i "%~1"=="--help" (
	echo.Batch Antivirus - Updater
	echo.
	echo.Syntax:
	echo.
	echo.BAVUpdate [--skip]
	echo.
	echo.Example:
	echo.
	echo.BAVUpdate
	echo.Will update Batch Antivirus to the latest version
	echo.
	echo Copyright ^(c^) 2023 anic17 Software
	exit /b
)
title Batch Antivirus Updater
echo Checking for updates...
set skipprompt=0
if /i "%~1"=="--skip" set skipprompt=1
set "files=BAV.bat BAVAutorun.bat BAVConfig.bat BAVDetail.bat BAVUpdate.bat BAVWebsiteBlocker.bat DeepScan.bat InstallIntercept.bat Quarantine.bat RealTimeProtection.bat ScanIntercept.bat USBCleaner.bat USBScan.bat VirusDataBaseHash.bav VirusDataBaseIP.bav gethex.exe sha256.exe waitdirchange.exe update\UpdateScript.bat"

set "outdir=!TMP!\Batch-Antivirus"
md "!outdir!" >nul 2>&1

(curl -V > nul 2>&1 && set "hasCurl=1") || set "hasCurl=0"
for %%A in ("database.ver" "BAVFiles.txt") do (
	if exist "!outdir!\%%~A" del "!outdir!\%%~A" /q > nul 2>&1
	call :download "%%~A" "!outdir!\%%~A" --silent
)
if exist "!outdir!\BAVFiles.txt" set /p files=<"!outdir!\BAVFiles.txt"
if not exist "!outdir!\database.ver" (
	echo Unable to retrieve latest version, are you connected to the internet?
	goto quit
)
if not exist "%~dp0VirusDataBaseHash.bav" (
	echo.No Batch Antivirus database found. Please redownload the program from the official GitHub.
	goto quit
)
set /p ver_db=<"%~dp0VirusDataBaseHash.bav"
set /p ver_online=<"!outdir!\database.ver"
set "ver_online=!ver_online::=!"
set "ver_db=!ver_db::=!"
set orig_ver_db=!ver_db!
set orig_ver_online=!ver_online!
set "ver_online=!ver_online:.=!"
set "ver_db=!ver_db:.=!"
echo.
if !ver_db! geq !ver_online! (
	echo.You're using the latest version of Batch Antivirus ^(v!orig_ver_db!^)
	goto quit
)
if "!skipprompt!"=="0" (
	echo.Newest version: v!orig_ver_online!, current version v!orig_ver_db!
	echo.A new version of Batch Antivirus is available, download? ^(y/n^)
	choice /c:YN /n
	if !errorlevel!==1 goto downloadnew
) else (
	goto downloadnew
)
goto quit

	
:download <file> <output>

if "!hasCurl!"=="1" (
	
	curl "https://raw.githubusercontent.com/anic17/Batch-Antivirus/master/%~1" --output "%~2" %~3
	if !errorlevel! equ 6 (
		echo.Failed to connect to the server. Make sure you're connected to the internet.
	)
) else (
	powershell -ExecutionPolicy Bypass -Command "$ProgressPreference = 'SilentlyContinue'; Invoke-WebRequest -Uri \"https://raw.githubusercontent.com/anic17/Batch-Antivirus/master/%~1\" -OutFile \"%~2\""
	if not exist "%~2" (
		echo.Failed to download the file. Make sure you're connected to the internet.
	)
)
exit /b !errorlevel!

:quit
if "!skipprompt!"=="0" (
	echo.
	echo.Press any key to quit...
	pause>nul
)
endlocal
exit /b %errorlevel%

:downloadnew
echo.
echo.Downloading version v!orig_ver_online!... Please do not close this window.
for %%A in (!files!) do (
	echo.Downloading '%%A'...
	call :download %%A "!outdir!\%%A" --progress-bar
	if exist "!outdir!\%%A" (
		echo.'%%A' downloaded successfully
	) else (
		echo.Failed to download '%%A': aborting update.
		goto quit
	)
)
echo.
echo.Applying update...
md "%~dp0OldVersions\v!orig_ver_db!" > nul 2>&1
set /a totalfiles=0,currfile=0
for %%X in (!files!) do (
	set /a totalfiles+=1
)

for /f %%# in ('copy /Z "%~dpf0" nul') do set "CR=%%#"
set /a totalfiles-=1
for %%A in (%files%) do (
	if "%%A" neq "%~nx0" (
		set /a currfile+=1
		set /a percent=100*currfile/totalfiles

		<nul set /p "=Replacing file [!currfile!/!totalfiles!] (!percent!%%)!CR!"
		move /y "%~dp0%%A" "%~dp0OldVersions\v!orig_ver_db!" > nul 2>&1
		move /y "!outdir!\%%A" "%~dp0%%A" > nul 2>&1
	)
)
echo.
echo.Batch Antivirus successfully updated to version v!orig_ver_online!
goto quit
	
