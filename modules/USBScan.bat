::BAV_:git@github.com:anic17/Batch-Antivirus.git
@echo off
setlocal EnableDelayedExpansion
set drive=0
if "%~1" neq "" set "drive=%~d1"
for /f %%A in ('copy /Z "%~dpf0" nul') do set "CR=%%A"
pushd "%~dp0"
title Batch Antivirus USB Malware Removal Tool
echo.Batch Antivirus USB Malware Removal Tool
echo.
echo.This Batch Antivirus utilityassists in removing malware from USB drives,
echo.both the widely spread USB shortcut malware and autorun malware.
echo.
echo.Batch Antivirus will now begin scanning for USB malware.
echo.Press any key to begin...
pause>nul
echo.
set /a scancount=0,threats=0
for /f %%A in ('copy /Z "%~dpf0" nul') do set "CR=%%A"
for %%# in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
	if exist %%#: (
		<nul set /p "=Scanning drive %%#: "
		set /a scancount+=1
		call :search "%%#:"
		call :scanshortcut "%%#:"
		echo.
	)
)
echo.
echo Scanned !scancount! drives, found !threats! threat(s)
echo.
echo.Press any key to quit...
pause>nul
endlocal | exit /b !threats!
exit /b 0

:search <disk>
set "drive=%~1"
attrib -h -s "!drive!\autorun.inf" >nul 2>&1
if exist "!drive!\autorun.inf" (
	pushd "!drive!"
	<nul set /p "=^(autorun.inf found at !drive!\autorun.inf^)"
	for /f "tokens=1,2* delims==" %%A in ('findstr /ric:"Open.*=" /c:"Shell.*=" "%~1\autorun.inf"') do for /f "delims=" %%# in ("%%~B") do (
		call :scanfile "%%~f#" "%%~#"
	)
	popd
)
goto :EOF

:scanfile
pushd "%~d1"
set "tp=%~2"
if "!tp:~1,2!"==":\" (
	set "filescan=!tp!"
) else (
	for /f "tokens=1* delims= " %%X in ("%~2") do set "filescan=%~d1\%%~X %%~Y"
)

call "%~dp0DeepScan.bat" "!filescan!" --verbose --novirustotal
set det=%detection%
set detectionratio=%errorlevel%
if !detectionratio! geq 20 (
	for /f %%A in ('sha256 "!filescan!"') do set hash=%%A
	set "hash=!hash:\=!"
	set /a threats+=1
	echo.
	echo.Malware detected in drive %~d1 ^| !detection! ^(!filescan!^)
	echo.Delete the malicious file? ^(y/n^)
	choice /c:YN /n
	if "!errorlevel!" equ "1" (
		del "!filescan!" /q /f > nul 2>&1
		if not exist "!filescan!" (
			echo.Successfully removed the malware !detection!
		) else (
			echo.Failed to remove the malware !detection!
			echo.Try running this program with administrative privileges.
		)
	)
)
popd	
goto :EOF

:scanshortcut
set "drive=%~d1"
set "drive=!drive:\=!"
set "drive=!drive::=!"
set "drive=!drive!:\"
if not exist "!drive!" exit /b

set cnt=0
if exist "!drive!\*.lnk" (
	if exist "!drive!\.Trashes" (
		set "threatname=JS/Bondat"
		echo Warning^^! Drive infected ^(!threatname!^)
		echo.
		echo.Do you want to delete all malicious shortcuts from !Drive! ? ^(y/n^)
		choice /c:YN /n
		if errorlevel 1 (
			echo Attempting to remove !threatname! ...
			md "%~dp0Data\Quarantine\USB\!Drive::=!"  > nul 2>&1
			attrib -h -s /d "!drive!\*.*"  > nul 2>&1
			move /y "!drive!\*.lnk" "%~dp0Data\Quarantine\USB\!Drive::=!" > nul 2>&1
			move /y "!drive!\*.exe" "%~dp0Data\Quarantine\USB\!Drive::=!" > nul 2>&1
			move /y "!drive!\*.vbs" "%~dp0Data\Quarantine\USB\!Drive::=!" > nul 2>&1
			move /y "!drive!\.trashes\*" "!drive!\" > nul 2>&1
			rd "!drive!\.trashes" > nul 2>&1
			if exist "!drive!\*.lnk" (
				echo Cleaning failed^^!
			) else (
				echo !threatname! was successfully removed from your system.
				echo.
				echo It is recommended to run a Batch Antivirus scan to ensure no malware is left on the system.
				echo.Do you want to run a full disk scan on !drive! ? ^(y/n^)
				choice /c:YN /n
				if !errorlevel!==1 (
					echo Running scan...
					if exist "%~dp0BAVDisk.bat" "%~dp0BAVDisk.bat" "!drive!\"
					
					
					exit /b %errorlevel%
				)
			)
		)
	)
		
)
exit /b


