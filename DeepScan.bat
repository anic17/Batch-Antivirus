@echo off
setlocal EnableDelayedExpansion
set dir=%CD%
path=%PATH%;%CD%
set ver=0.1.0

set "string[severe]=Severe malware found."
set "string[malware]=Malware found."
set "string[suspicious]=Suspicious file."
set "string[possibly]=Possibly clean file."
set "string[clean]=Clean file."
set "string[safe]=Safe file."


set "argv[1]=%~1"
if not defined argv[1] (
	echo.Required parameter missing. Try with '%~n0 --help'.
	endlocal & exit /b
)

if /i "%~1"=="--help" goto help
title Batch AntiVirus Heuristic Analyser

set admin=1
set ratio=0
set threats=0

net session 2>nul 1>nul || set admin=0

echo.
echo Scanning file...
echo.
set "current_dir=%CD%"
echo on
set "filescan=%~f1"
set head=
set head2=
set "keys_findstr=uy9zQrvd %ÂdfsxÀp:$q,h*OanÅÊ|Î"1/n0 0".ÄÁ~ºÈi}2*S~1*""nKa%c"K84"0H *$0fd,1cq""pH¨*Þ*ft~þ<*k+þB"b%::K¨a%"~:¿/Z  uÀÊ%0yci&­0Ã^*|.&c%ßT%/"ÄÛr|%/yC}C~i&Lw@]["b'p0EC kFËþ0tT%3> Qº\GÈn %0dt|©%6Ar~f"°/xnz"//È²*X%/º~l¹4:dE#*pJ¼|$-;Û%fc,O|%Kºl¼Op~gzx0#bÈÝ^"%*ÅEY'd6 fc%;j:0/cY*0/Í~ËÎkiÛr-c*]3:~gcnfex//R"y±1Ã@&~º(7*,"CV¼Zx%0~U0q|0"

findstr /r /i /c:"%%0*|*%%0" /c:"%%~f0*|*%%~f0" /c:"%%~dpnx0*|*%%~dpnx0" /c:"%%~f0*|*%%0" /c:"%%0*|*%%~f0" /c:"%%~dpnx0*|*%%~f0" /c:"%%~f0*|*%%~dpnx0" "%filescan%" > nul 2>&1 && echo.!string[malware]! && exit /b
if not exist "%filescan%" (
	echo.Could not find '%filescan%'
	exit /b 1
)
for /f "usebackq eol=: delims=" %%A in ("%filescan%") do if not defined head (set "head=%%A") else if not defined head2 set "head2=%%A"

set "head=!head:"=!"
set "head=!head:&=!"
set "head=!head:@=!"

for /f "tokens=1,* delims= " %%A in ("%head%") do set "head_tok1=%%A" && set "head_tok2=%%B"
set "head_tok1=!head_tok1:"=!"
set "head_tok2=!head_tok2:"=!"
set "head_tok1=!head_tok1:&=!"
set "head_tok2=!head_tok2:&=!"
set "head_tok1=!head_tok1:@=!"
set "head_tok2=!head_tok2:@=!"
if /i "%head%"=="echo off" (set "mime=application/x-bat") else if /i "%head_tok1%"=="echo" (set "mime=application/x-bat") else if "%head_tok1%"=="shift" (set "mime=application/x-bat") else set "mime=bin"
if "%mime%"=="application/x-bat" goto scanbatch
exit /b

exit /b
echo yep lol
findstr /r /i /c:"*\.*\.*\.*" /c:"http://" /c:"www\." /c:"https://" "%filescan%"
findstr /r "%filescan%"







echo yep lol 2
exit /b


:: Get file hash
for /f %%A in ('sha256.exe "%~1" 2^>nul') do (set "hash=%%A" & goto scan)

:hashed


set "hash=%~1"
set "hash=%hash:~1%"

findstr /c:"%hash%" "%~dp0VirusDataBaseHash.bav" > nul || exit /B

for /f "tokens=1,2* delims=:" %%a in ('findstr /c:"%hash%" "%~dp0VirusDataBaseHash.bav"') do (call :detection "%%~a" "%%~b")
goto :EOF

:detection
if "%~1" neq "%hash%" goto :EOF

start /b powershell [Reflection.Assembly]::LoadWithPartialName("""System.Windows.Forms""");$obj=New-Object Windows.Forms.NotifyIcon;$obj.Icon = [drawing.icon]::ExtractAssociatedIcon($PSHOME + """\powershell.exe""");$obj.Visible = $True;$obj.ShowBalloonTip(100000, """Batch Antivirus""","""Threats found: %~2""",2)>nul
if "%~1"=="%hash%" (echo Malware found: !filescan! ^| %~2) || goto :EOF
md "%DIR%\Data\Quarantine\!hash!" 2>nul 1>nul
icacls %filescan% /setowner %username% 2>nul 1>nul
icacls %filescan% /grant %username%:(F,MA,WA,RA,WEA,REA,WDAC,DE) 2>nul 1>nul

move %filescan% "%DIR%\Data\Quarantine\!hash!\!hash!" /y 2>nul 1>nul
icacls "%DIR%\Data\Quarantine\!hash!\!hash!" /deny %username%:(RX,W,R,M,RD,WEA,REA,X,RA,WA) 2>nul 1>nul
set /a threats+=1
if not exist %filescan% (echo Malware successfully quarantined) else (echo Error while deleting malware)
goto :EOF
:not_found_possible_malware







echo Scanned "%~dpnx1" and found !threats! threats
pause>nul
exit /B %errorlevel%


:hash_getdetection
for /f "eol=: tokens=1,2* delims=:" %%a in ('findstr /i /c:"%hash%" "%~dp0VirusDataBaseHash.bav"') do (









call :detection "%%~a" "%%~b")
goto :EOF

:detection

if "%~1"=="%hash%" echo Malware found: !filescan! ^| %~2 || goto :EOF
md "%DIR%\Data\Quarantine\!hash!" 2>nul 1>nul
icacls %filescan% /setowner %username% 2>nul 1>nul
icacls %filescan% /grant %username%:(F,MA,WA,RA,WEA,REA,WDAC,DE) 2>nul 1>nul

move /y "%filescan%" "%DIR%\Data\Quarantine\!hash!\!hash!" 2>nul 1>nul
icacls "%DIR%\Data\Quarantine\!hash!\!hash!" /deny %username%:(RX,W,R,M,RD,WEA,REA,X,RA,WA) 2>nul 1>nul
set /a threats+=1
if not exist "%filescan%" (echo Malware successfully quarantined) else (call :delete)
goto :EOF

:delete
echo.
echo Failed to quarantine malware^^!
set /p "delmalware=Delete malware? (y/n): "
icacls %filescan% /setowner %username% 2>nul 1>nul
icacls %filescan% /grant %username%:(F,MA,WA,RA,WEA,REA,WDAC,DE) 2>nul 1>nul
if /i "%delmalware%"=="y" del !filescan! /s /q > nul
echo.
goto :EOF

:scanbatch
set "mimikatz_key=±-Âb-,znI<tiWPY4wNb)Ùpr»y=^MeTP0-i}oAk-Êkvma*°;"
set "text="
for %%A in (8;7;41=35;40;28,38=27,11 42 33 37 43=10 6) do set "text=!text!!mimikatz_key:~%%A,1!"
set ratio=0
:: 1 + 3 + 1 + 4 + 1 + 1 + 4 + 5 = 20
findstr /r /i /c:"*.*.*.*" /c:"http://" /c:"www\." /c:"https://" /c:"ftp://" /c:"sftp://" "%filescan%" > nul 2>&1 && set /a ratio+=1
findstr /i /c:"del %HomeDrive%\*" /c:"del %%HomeDrive%%\*"/c:"erase %HomeDrive%\*" /c:"erase %%HomeDrive%%\*" "%filescan%" > nul 2>&1 && set /a ratio+=3
findstr /ic:"ping www.*.*" "%filescan%" > nul 2>&1 && set /a ratio+=1
findstr /ic:"!text!" "%filescan%" > nul 2>&1 && set /a ratio+=9
findstr /ic:"vssadmin" "%filescan%" > nul 2>&1 && set /a ratio+=1
findstr /ic:"bcdedit" "%filescan%" > nul 2>&1 && set /a ratio+=1
findstr /r /i /c:"taskkill * /im explorer.exe *" "%filescan%" > nul 2>&1 && set /a ratio+=1
findstr /r /i /c:"taskkill*/im csrss.exe*" /c:"taskkill * /im System *" /c:"taskkill*/im wininit.exe *" /c:"taskkill * /im svchost.exe *"  /c:"taskkill * /im services.exe *" "%filescan%" > nul 2>&1 && set /a ratio+=5

if %ratio% equ 20 (
	echo.!string[severe]!
	exit /b %ratio%
)
if %ratio% leq 19 if %ratio% geq 15 (
	echo.!string[malware]!
	exit /b %ratio%
)
if %ratio% leq 14 if %ratio% geq 10 (
	echo.!string[suspicious]!
	exit /b %ratio%
)
if %ratio% leq 9 if %ratio% geq 5 (
	echo.!string[possibly]!
	exit /b %ratio%
)
if %ratio% leq 4 if %ratio% geq 1 (
	echo.!string[clean]!
	exit /b %ratio%
)
if %ratio% equ 0 (
	echo.!string[safe]!
	exit /b %ratio%
)
exit /b %ratio%