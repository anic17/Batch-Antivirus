::BAV_:git@github.com:anic17/Batch-Antivirus.git
@echo off
setlocal EnableDelayedExpansion
title Batch Antivirus USB Scanner
set "drives=ABCDEFGHIJKLMNOPQRSTUVWXYZ"
set /a scancount=0,threats=0
for /f %%A in ('copy /Z "%~dpf0" nul') do set "CR=%%A"

for %%# in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
	
	
	if exist %%#: (
		echo.Scanning drive %%#:
		set /a scancount+=1
		call :search "%%#:"
	)
)
echo.
echo Scanned !scancount! drives, found !threats! threat(s)
echo.
echo.Press any key to quit...
pause>nul
endlocal | exit /b !threats!

:search <disk>
set "drive=%~1"
attrib -h -s "!drive!\autorun.inf" >nul 2>&1
if exist "!drive!\autorun.inf" (
	pushd "!drive!"
	for /f "tokens=1,2* delims==" %%A in ('findstr /ric:"Open.*=" "%~1\autorun.inf"') do for /f "delims=" %%# in ("%%~B") do (
		call :scanfile "%%~f#"
	)
	popd
)
goto :EOF

:scanfile
set "filescan=%~1"
call "%~dp0DeepScan.bat" "!filescan!" --verbose --novirustotal
set detectionratio=%errorlevel%
if !detectionratio! geq 20 (
	for /f %%A in ('sha256 "!filescan!"') do set hash=%%A
	set "hash=!hash:\=!"
	set /a threats+=1
	for /f "tokens=1* delims=:" %%A in ('findstr /c:"!hash!" "%~dp0VirusDataBaseHash.bav"') do (
		if "%%A"=="!hash!" (
			echo Malware detected in '!filescan!' ^(drive %~d1^) ^| Detection name: %%B
		)
	)
)
goto :EOF