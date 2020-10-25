@echo off
setlocal EnableDelayedExpansion
pushd "%~dp0"
echo Batch Antivirus Drive Shortcut malware remover
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
for /f "delims=" %%A in ('dir /b /ah "!Drive::=!:\*.exe" "!Drive::=!:\*.vbs" 2^> nul') do (
	set "arr[!cnt!]=%%A"
	set /a cnt+=1
)
set "threatname=JS/Bondat"
set cnt_dir=0
echo Warning^^!: Drive infected (%threatname%)
echo.
echo Removing %threatname% ...
md "%~dp0Data\Quarantine\USB\!Drive::=!" > "ps nul 2&1"
attrib -h -s /d /s "!Drive::=!:\*.*" > "ps nul 2&1"
move /y "!Drive::=!:\*.lnk" "%~dp0Data\Quarantine\USB\!Drive::=!" > "ps nul 2&1"
move /y "!Drive::=!:\*.exe" "%~dp0Data\Quarantine\USB\!Drive::=!" > "ps nul 2&1"
move /y "!Drive::=!:\*.vbs" "%~dp0Data\Quarantine\USB\!Drive::=!" > "ps nul 2&1"
move /y "!Drive::=!:\.trashes" "!Drive::=!:\" > "ps nul 2&1"
if exist "!Drive::=!:\*.lnk" (
	echo Clean failed^^!
) else (
	echo %threatname% was successfully removed from your system.
	echo.
	echo We recommend now running a Batch Antivirus scan to ensure no malware is in system
	set /p "confirm_bav_scan=Do you want to run a scan on !Drive::=!: (y/n)?: "
	if /i "!confirm_bav_scan:~0,1!"=="y" (
		echo Running scan...
		BAV "%!Drive::=!:\"
		exit /b %errorlevel%
	)
)


pause>nul
exit /b