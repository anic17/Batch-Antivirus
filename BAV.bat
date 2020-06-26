@echo off
setlocal EnableDelayedExpansion
if not exist "VirusDataBaseHash.bav" (
	echo FATAL: Could not find 'VirusDataBaseHash.bav'^^!
	echo Batch AntiVirus cannot start
	pause>nul
	exit /B 3
)
set dir=%CD%
path=%PATH%;%CD%
set ver=0.1.0
title Batch AntiVirus
if /i "%~1"=="--help" goto help
color 07
mode con: cols=120 lines=30
:database_check
echo Checking for database updates...

md "%TMP%\Batch-AntiVirus" 2>nul 1>nul

takeown /f "%TMP%\Batch-AntiVirus" 2>nul 1>nul
icacls "%TMP%\Batch-AntiVirus" /setowner "%username%" 2>nul 1>nul

icacls "%TMP%\Batch-AntiVirus" /grant "%username%":(F,MA) /t 2>nul 1>nul

powershell -Command Invoke-WebRequest -Uri "https://raw.githubusercontent.com/anic17/Batch-AntiVirus/master/VirusDataBaseHash.bav" -OutFile "%TMP%\Batch-AntiVirus\VirusDataBaseHash.bav"
for /f %%H in ('sha256 "%TMP%\Batch-AntiVirus\VirusDataBaseHash.bav"') do (set "hashnewdatabase=%%H")
for /f %%H in ('sha256 "VirusDataBaseHash.bav"') do (set "hasolddatabase=%%h")
if /i "%hashnewdatabase%" neq "%hasolddatabase%" (
	echo Update found: Installing...
	move "%~dp0VirusDataBaseHash.bav" "%~dp0VirusDataBaseHash.bav.old" /y 2>nul 1>nul
) else (
	echo No update found
)
echo.
echo Scanning system for threats...
echo.
set scanned_files=0
set threats=0
cd/
if "%~1" neq "" cd /d "%~1"
for /r %%a in (*.*) do (call :scan "%%~a") 2> nul
echo Scan finished.
echo.
echo Result: !scanned_files! scanned files and !threats! threat(s) found
echo.
echo Press any key to quit...
pause>nul
exit /B %errorlevel%

:scan
title Scanning now: %* ; !scanned_files! scanned files, !threats! threat(s) found
set filescan=%*
	for /f %%A in ('sha256.exe "%~1" 2^>nul ') do (call :hashed %%A)

)
set /a scanned_files+=1 & set filescan=
goto :EOF

:hashed

set "hash=%~1"
set "hash=%hash:~1%"

findstr /c:"%hash%" "%~dp0VirusDataBaseHash.bav" > nul || exit /B

for /f "usebackq eol=: tokens=1,2* delims=:" %%a in ("%~dp0VirusDataBaseHash.bav") do (call :detection "%%~a" "%%~b")
goto :EOF
:detection
if "%~1" neq "%hash%" goto :EOF
if "%~1"=="%hash%" (echo Malware found: !filescan! ^| %~2) || goto :EOF
md "%DIR%\Data\Quarantine\!hash!" 2>nul 1>nul
move %filescan% "%DIR%\Data\Quarantine\!hash!\!hash!" 2>nul 1>nul
icacls "%DIR%\Data\Quarantine\!hash!\!hash!" /deny %username%:(RX,W,R,M,RD,WEA,REA,X,RA,WA) 2>nul 1>nul
set /a threats+=1
if not exist %filescan% (echo Malware successfully quarantined) else (call :delete)
goto :EOF

:delete
echo.
echo Failed to quarantine malware
set /p "delmalware=Delete malware? (y/n): "
if /i "%delmalware%"=="y" del !filescan! /s /q > nul
echo.
goto :EOF

:help
echo.
echo Batch AntiVirus %ver% - Help menu
echo.
echo Syntax:
echo.
echo BAV "[folder]"
echo.
echo Examples:
echo.
echo BAV
echo Will do an scan in all current drive. This may take some time depending
echo of the number of files and the speed of your computer.
echo.
echo BAV "%USERPROFILE%"
echo Will scan the folder "%USERPROFILE%" and all it's subdirectories
echo It is recommended for more precise scan
echo.
echo Batch AntiVirus will check at every startup new database updates to guarantee
echo that you have always the most updated database
echo.
echo Official GitHub repository:
echo https://github.com/anic17/Batch-AntiVirus
echo.
echo.
echo Copyright (c) 2020 anic17 Software
endlocal
exit /B 0