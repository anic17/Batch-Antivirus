::BAV_:git@github.com:anic17/Batch-Antivirus.git
@echo off
setlocal EnableDelayedExpansion
if "%~1"=="" (
	echo.Missing arguments. This program shouldn't be run manually.
	pause>nul
	exit /b
)
if "%~f0"=="%~f1" (
	echo.Cannot run this program recursively.
	pause>nul
	exit /b 0
)
set balloon_notification_timeout=100000
set "command_args=%*"
set "file=%~1"
call "%~dp0DeepScan.bat" "!file!" --verbose --novirustotal
set ret_deepscan=%errorlevel%
if %ret_deepscan% lss 20 (
	"!file!" !command_args!
	pause
	exit /b %errorlevel%
)
call "%~dp0BAVConfig.bat"
echo.Malware found: !file!
pause>nul
exit /b 0