::BAV_:git@github.com:anic17/Batch-Antivirus.git
@echo off
setlocal EnableDelayedExpansion
pushd "%~dp0"
title Batch Antivirus Shortcut Malware Remover
echo Batch Antivirus drive shortcut malware remover
echo.
echo.This utility will help in the removal of the widely-spread USB shortcut malware.
echo.
echo.It will also restore the original files.
echo.
set /p "Drive=Drive to disinfect > "
if not exist "%Drive::=%:" (
	echo Could not find %Drive::=%: drive
	pause>nul
	exit /b
)
echo Scan started...
set cnt=0
if not exist "!Drive::=!:\*.lnk" (
	if not exist "!Drive::=!:\.Trashes" (
		echo.
		echo Drive is not infected
		pause>nul
		exit /b
	)
)
set "threatname=JS/Bondat"
set cnt_dir=0
echo Warning^^!: Drive infected (%threatname%)
echo.
echo Removing %threatname% ...
md "%~dp0Data\Quarantine\USB\!Drive::=!"  > nul 2>&1
attrib -h -s /d /s "!Drive::=!:\*.*"  > nul 2>&1
move /y "!Drive::=!:\*.lnk" "%~dp0Data\Quarantine\USB\!Drive::=!" > nul 2>&1
move /y "!Drive::=!:\*.exe" "%~dp0Data\Quarantine\USB\!Drive::=!" > nul 2>&1
move /y "!Drive::=!:\*.vbs" "%~dp0Data\Quarantine\USB\!Drive::=!" > nul 2>&1
move /y "!Drive::=!:\.trashes" "!Drive::=!:\" > nul 2>&1
if exist "!Drive::=!:\*.lnk" (
	echo Clean failed^^!
) else (
	echo !threatname! was successfully removed from your system.
	echo.
	echo It is recommended to run a Batch Antivirus scan to there's no malware left in the system
	echo.Do you want to run a scan on !Drive::=!: ? (y/n)
	choice /c:YN /n
	if !errorlevel!==1 (
		echo Running scan...
		BAV "%!Drive::=!:\"
		exit /b %errorlevel%
	)
)


pause>nul
exit /b