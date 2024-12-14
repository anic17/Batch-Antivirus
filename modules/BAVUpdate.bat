::BAV_:git@github.com:anic17/Batch-Antivirus.git
@echo off
setlocal EnableDelayedExpansion
pushd  "%~dp0"
cd "modules" > nul 2>&1
cd ..
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
set "files=modules\BAVAutorun.bat modules\BAVConfig.bat modules\BAVDetail.bat modules\BAVDisk.bat modules\BAVIntercept.bat modules\BAVStatus.bat modules\BAVUpdate.bat BAVWebsiteBlocker.bat modules\DeepScan.bat modules\Quarantine.bat modules\RealTimeProtection.bat modules\USBCleaner.bat modules\USBScan.bat modules\VirusDataBaseHash.bav modules\VirusDataBaseIP.bav BAV.bat"

set "outdir=!TMP!\Batch-Antivirus"
md "!outdir!" >nul 2>&1

(curl -V > nul 2>&1 && set "hasCurl=1") || set "hasCurl=0"
for %%A in ("update\database.ver" "update\BAVFiles.txt") do (
	if exist "!outdir!\%%~A" del "!outdir!\%%~A" /q > nul 2>&1
	call :download "%%~A" "!outdir!\%%~A" --silent
)

if exist "!outdir!\BAVFiles.txt" set /p files=<"!outdir!\update\BAVFiles.txt"
if not exist "!outdir!\database.ver" (
	echo Unable to retrieve latest version, are you connected to the internet?
	goto quit
)
if not exist "%CD%\modules\VirusDataBaseHash.bav" (
	echo.No Batch Antivirus database found. Please redownload Batch Antivirus from the official GitHub.
	goto quit
)
set /p ver_db=<"%CD%\modules\VirusDataBaseHash.bav"
set /p ver_online=<"!outdir!\update\database.ver"
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
set /a ver_diff=(ver_online - ver_db)/100
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

set "download_url=%~1"
set "download_url=!download_url:\=/!"
if "!hasCurl!"=="1" (
	mkdir "%~dp2" > nul 2>&1
	curl "https://raw.githubusercontent.com/anic17/Batch-Antivirus/master/!download_url!" --output "%~2" %~3
	if !errorlevel! equ 6 (
		echo.Failed to connect to the server. Make sure you are connected to the internet.
	)
) else (
	powershell -ExecutionPolicy Bypass -Command "$ProgressPreference = 'SilentlyContinue'; Invoke-WebRequest -Uri \"https://raw.githubusercontent.com/anic17/Batch-Antivirus/master/!download_url!\" -OutFile \"%~2\""
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
popd
endlocal
exit /b %errorlevel%

:downloadnew
echo.
echo.Downloading version v!orig_ver_online!... Please do not close this window.
set "uscript=update\BAVUpdateScript.bat"

for %%A in (!files! !uscript!) do (
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
md "%CD%\OldVersions\v!orig_ver_db!" > nul 2>&1
set /a totalfiles=0,currfile=0
for %%X in (!files!) do (
	set /a totalfiles+=1
)

for /f %%# in ('copy /Z "%~dpf0" nul') do set "CR=%%#"
set /a totalfiles-=1
for %%A in (!files!) do (
	if "%%~nxA" neq "%~nx0" (
		set /a currfile+=1
		set /a percent=100*currfile/totalfiles

		<nul set /p "=Replacing file [!currfile!/!totalfiles!] (!percent!%%)!CR!"
		move /y "%CD%\%%A" "%CD%\OldVersions\v!orig_ver_db!" > nul 2>&1
		for /f "delims=" %%X in ("%CD%\%%A") do mkdir "%%~dpX" > nul 2>&1
		
		move /y "!outdir!\%%A" "%CD%\%%A" > nul 2>&1
	)
)
echo.
<nul set /p "=Running update script..."
call "!outdir!\!uscript!" "!ver_db!" "!ver_online!" "%~dp0"
echo.
echo.Batch Antivirus successfully updated to version v!orig_ver_online!
goto quit
	
