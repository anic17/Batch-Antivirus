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
	echo Copyright ^(c^) 2024 anic17 Software
	exit /b
)
if "!check_updates!"=="0" exit /b
title Batch Antivirus Updater
echo Checking for updates...
set skipprompt=0
if /i "%~1"=="--skip" set skipprompt=1
set "files=BAVAutorun.bat BAVConfig.bat BAVDetail.bat BAVDisk.bat BAVInstall.bat BAVIntercept.bat BAVStatus.bat BAVUpdate.bat BAVUpdateScript.bat BAVWebsiteBlocker.bat DeepScan.bat Quarantine.bat RealTimeProtection.bat USBCleaner.bat USBScan.bat"

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
	echo.No Batch Antivirus database found. Please redownload Batch Antivirus from the official GitHub.
	goto quit
)
set /p ver_db=<"%~dp0VirusDataBaseHash.bav"
set /p ver_online=<"!outdir!\database.ver"
for /f "tokens=1* delims==" %%A in ('findstr /c:"updatemsg=" "!outdir!\database.ver"') do (
	set "updatemsg=%%B"
	echo.
	echo.!updatemsg!
)
set "ver_online=!ver_online::=!"
set "ver_db=!ver_db::=!"
set orig_ver_db=!ver_db!
set orig_ver_online=!ver_online!
set "ver_online=!ver_online:.=!"
set "ver_db=!ver_db:.=!"
echo.
set /a ver_diff=(!ver_online! - !ver_db!)/100
set /a major_bld=!ver_db!/100
if !ver_diff! gtr 0 (
	set release_ver=https://github.com/anic17/Batch-Antivirus/releases/tag/v!major_bld!.0.0
	echo.The newest Batch Antivirus version is v!orig_ver_db!
	echo.
	echo.Because it is a major release, it cannot be updated from this script
	echo.and must be downloaded directly from the GitHub releases:
	echo.!release_ver!
	echo.
	echo.Press any key to open this URL and quit...
	pause>nul
	set skipprompt=1
	start "" "!release_ver!"
	goto quit
)
if !ver_db! geq !ver_online! (
	echo.You are using the latest version of Batch Antivirus ^(v!orig_ver_db!^)
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
		echo.Failed to connect to the server. Make sure you are connected to the internet.
	)
) else (
	powershell -ExecutionPolicy Bypass -Command "$ProgressPreference = 'SilentlyContinue'; Invoke-WebRequest -Uri \"https://raw.githubusercontent.com/anic17/Batch-Antivirus/master/%~1\" -OutFile \"%~2\""
	if not exist "%~2" (
		echo.Failed to download the file. Make sure you are connected to the internet.
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
:: Update script is downloaded separately
set "uscript=BAVUpdateScript.bat"
echo.Downloading '!uscript!'...
	call :download "update\!uscript!" "!outdir!\!uscript!" --progress-bar
	if exist "!outdir!\!uscript!" (
		echo.'!uscript!' downloaded successfully
	) else (
		echo.Failed to download '!uscript!': aborting update.
		goto quit
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
<nul set /p "=Running update script..."
call "!outdir!\!uscript!" "!ver_db!" "!ver_online!" "%~dp0"
echo.
echo.Batch Antivirus successfully updated to version v!orig_ver_online!
goto quit
	
