::BAV_:git@github.com:anic17/Batch-Antivirus.git

@echo off
if "%~f1"=="%~f0" echo Safe file (Whitelisted). && exit /b
setlocal EnableDelayedExpansion
set dir=%CD%
path=%PATH%;%CD%
set ver=0.1.0
set report=1
set "string[severe]=Severe malware found."
set "string[malware]=Malware found."
set "string[possibly]=Suspicious indicator in file."
set "string[clean]=Clean file."
set "string[safe]=Safe file."


set "argv[1]=%~1"
if not defined argv[1] (
	echo.Required parameter missing. Try with '%~n0 --help'.
	endlocal & exit /b
)

if /i "%~1"=="--help" goto help
title Batch Antivirus Heuristic Analyser

set admin=1
set ratio=0
set threats=0

(net session 2>nul 1>nul && set "admin=1")|| set admin=0

echo.
for /f %%A in ('copy /Z "%~dpf0" nul') do set "CR=%%A"
<nul set /p "=Scanning file..."

set "current_dir=%CD%"

set "filescan=%~f1"
set head=
set head2=
for /f "usebackq eol=; delims=" %%A in ("%filescan%") do if not defined head (set "head=%%A") else if not defined head2 set "head2=%%A" && goto getting_wl

:getting_wl
set obfuscated=
set bfp=
::if "%head:~0,2%"=="MZ" goto scanexe
::echo.%HEAD%


if "%head%"=="::BAV_:git@github.com:anic17/Batch-Antivirus.git" (
	echo.!cr!Scan finished.   
	echo.
	echo Safe file.
	exit /b 0
)


findstr /i /c:"%%0|%%0" /c:"%%~f0|%%~f0" /c:"%%~dpnx0|%%~dpnx0" /c:"%%~f0|%%0" /c:"%%0|%%~f0" /c:"%%~dpnx0|%%~f0" /c:"%%~f0|%%~dpnx0" "%filescan%" > nul 2>&1 && echo.!string[malware]! && exit /b
if not exist "%filescan%" (
	echo.Could not find '%filescan%'
	exit /b 1
)


if /i "%~x1"==".cmd" goto scanbatch
if /i "%~x1"==".bat" goto scanbatch

:gothead
if "%head%"==":BFP" set bfp=1
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

for %%A in ("echo" "if exist" "shift" "prompt" "title" "setlocal") do if "%%~A"=="!head!" set "mime=application/x-bat"
if "!mime!"=="application/x-bat" goto scanbatch

for %%A in ("#^!/usr/bin/python" "#^!/bin/python" "from" "import"

) if "%%~A"=="!head_tok1!" set "mime=text/python

set mime=bin

echo.MIME is !mime!
rem echo this is an exe file
exit /b



exit

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
if not exist %filescan% (echo Malware successfully quarantined) else (echo Error while quarantining malware)
goto :EOF

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



set "in2=@if defined"
set "batch_=_out"


findstr /ic:"%in2%%batch_% %%%%~G" "%filescan%" > nul 2>&1 && (set "in2batch=1") || (set "in2batch=0")

for /f %%A in ('gethex.exe "%filescan%" 100') do set "head=%%A"
if /i "%head:~0,2%"=="feff" set "obfuscated=1"&set "obfc=FE FF"
if /i "%head:~0,2%"=="fffe" set "obfuscated=1"&set "obfc=FF FE"
if /i "%head:~0,4%"=="fffe0000" set "obfuscated=1"&set "obfc=FF FE 00 00"

if "%head:~0,4%"=="ÿþ  " set "obfuscated=1"&set "ofc=FF FE 00 00"&set "extra_info=FF FE 00 00"
if "%head:~0,2%"=="þÿ" set "obfuscated=1"&set "obfc=FE FF"&set "extra_info=FE FF"
if "%head:~0,2%"=="ÿþ" set "obfuscated=1"&set "obfc=FF FE"&set "extra_info=FF FE"
if "%head:~0,4%"==":BFP" set bfp=1
if "%head:~0,2%"=="MZ" (echo You are reading a binary file.&exit/B)
if "%BFP%"=="1" set head=
if "%BFP%"=="1" (
	
	del "%TMP%\bav_deepscan.bfp" /q > nul 2>&1
	del "%TMP%\bav_deepscan.b64" /q > nul 2>&1
	del "%TMP%\bav_deepscan.file" /q > nul 2>&1
	findstr /vc:"echo." /c:"echo " /c:"for " /c:":" /c:"rem " /c:"certutil -" /c:")" /c:"del " /c:"expand" /c:"%%*" /vc:"erase" "%filescan%" | findstr /vc:"-" /c:"_" /c:"\" /c:" > "%TMP%\bav_deepscan.b64"

	certutil -decode -f "%TMP%\bav_deepscan.b64" "%TMP%\bav_deepscan.bfp"  > nul
	expand "%TMP%\bav_deepscan.bfp" "%TMP%\bav_deepscan.file" > nul
	set "filescan=%TMP%\bav_deepscan.file"
	del "%TMP%\bav_deepscan.bfp" /q > nul 2>&1
	del "%TMP%\bav_deepscan.b64" /q > nul 2>&1
)
if "%in2batch%"=="1" (
	findstr /bic:"echo " "%filescan%" > "%TMP%\bav.deepscan.in2batch"
)
if "%BFP%"=="1" for /f "usebackq delims=" %%A in ("!filescan!") do if not defined head (set "head=%%A") else if not defined head2 set "head2=%%A" && goto getting_wl_bfp
if defined bfp set "extra_info=BFP"
:getting_wl_bfp
for /f %%A in ('gethex.exe "%filescan%" 100') do set "head=%%A"
if /i "%head:~0,2%"=="feff" set "obfuscated=1"&set "obfc=FE FF"
if /i "%head:~0,2%"=="fffe" set "obfuscated=1"&set "obfc=FF FE"
if /i "%head:~0,4%"=="fffe0000" set "obfuscated=1"&set "obfc=FF FE 00 00"



if "%head%"=="3a3a4241565f3a676974406769746875622e636f6d3a616e696331372f42617463682d416e746976697275732e676974" (
	echo.!cr!Scan finished.  
	echo.
	echo.Safe file.
	exit /b 0
)
set "mk_key=YÎf¿mzkkmt-Yiika"
set "text="
for %%A in (4=12=8,13;7,15=9=5,) do set "text=!text!!mk_key:~%%A,1!"
set ratio=0

set "pn=pin"
set "ic=icac"
set "sch=schta"
set "net=nets"
set "psx=psexe"
set "bcde=bcded"
set "vssa=vssadm"


findstr /vc:"echo" /vc:":" /ivc:"rem" "%filescan%" | findstr /i /c:"*\.*\.*\.*" /c:"http://" /c:"www\." /c:"https://" /c:"ftp://" /c:"sftp://" /c:"cURL" /c:"wget" /c:"Invoke-WebRequest" /c:"bitsadmin" /c:"certutil -urlcache" /c:"createobject(\"Microsoft\.XMLHTTP\")"> nul 2>&1 && set /a ratio+=1 && set "report_http_ftp=Contacts an FTP server/makes an HTTP request (+1^)"
findstr /i /c:"del *" /c:"del %%HomeDrive%%\*" /c:"erase %HomeDrive%" /c:"erase %%HomeDrive%%\*" "%filescan%" > nul 2>&1 && set /a ratio+=3 && set "report_delete=Deletes files (+3^)"

findstr /vic:"echo" "%filescan%" | findstr /bic:"%pn%g " /c:"%pn%g.exe ">nul 2>&1 && set /a ratio+=1 && set "report_ping=Pings website/IP (+1^)"
findstr /vic:"echo" "%filescan%" | findstr /bic:"%ic%ls " /c:"%ic%ls.exe ">nul 2>&1 && set /a ratio+=1 && set "report_icacls=Changes ACL of a file or directory (+1^)"
findstr /vic:"echo" "%filescan%" | findstr /bic:"%sch%sks " /c:"%sch%sks.exe ">nul 2>&1 && set /a ratio+=1 && set "report_schtasks=Modifies scheduled tasks (+1^)"
findstr /vic:"echo" "%filescan%" | findstr /bic:"%net%h " /c:"%net%h.exe " >nul 2>&1 && set /a ratio+=1 && set "report_netsh=Runs network shell to edit or get configuration (+1^)"
findstr /vic:"echo" "%filescan%" | findstr /bic:"psexec " /c:"%psx%c." /c:"%psx%c64 " /c:"%psx%c64." >nul 2>&1 && set /a ratio+=1 && set "report_psexec=Uses PSExec to run remote commands"

:: Find Mimikatz string (encoded to evit self-false positives)
findstr /ic:"!text:_=-!" "%filescan%" > nul 2>&1 && set /a ratio+=5 && set "report_mimikatz=Uses HackTool/Mimikatz  (+5^)"
findstr /ic:"%vssa%in " "%filescan%" > nul 2>&1 && set /a ratio+=1 && set "report_vssadmin=Uses VSSAdmin command to manage shadow copies (+1^)"
findstr /ic:"%bcded%it " "%filescan%" > nul 2>&1 && set /a ratio+=1 && set "report_bcdedit=Uses BCDEdit command to edit boot configuration data (+1^)"
findstr /bvc:"echo" /vc:":" /ivc:"rem" /bvc:"echo" "%filescan%" 2>nul | findstr /ic:"taskkill /f /im " /c:"taskkill /im" /c:"taskkill /fi" /c:"taskkill /pid" /c:"taskkill /f" /c:"pskill " /c:"pskill.exe" /c:"pskill64 " /c:"tskill " /c:"tskill.exe" "%filescan%" > nul 2>&1 && set /a ratio+=1 && set "report_taskkill=Finishes processes (+1^)" && findstr /i /c:"csrss" /c:"wininit" /c:"svchost" /c:"services" /c:"explorer" /c:"msmpeng" /c:"%filescan%" > nul 2>&1 && set /a ratio+=5 && set "report_taskkill_critical=Finishes system critical processes (+5^)"

echo.!cr!Scan finished.   
echo.
if "%report%" equ "1" (
	echo Batch Antivirus report:
	echo.
	if %ratio% equ 0 echo No suspicious indicators found.
	if defined report_bcdedit echo.%report_bcdedit%
	if defined report_delete echo.%report_delete%
	if defined report_http_ftp echo.%report_http_ftp%
	if defined report_mimikatz echo.%report_mimikatz%
	if defined report_ping echo.%report_ping%
	if defined report_icacls echo.%report_icacls%
	if defined report_schtasks echo.%report_schtasks%
	if defined report_netsh echo.%report_netsh%
	if defined report_taskkill echo.%report_taskkill%
	if defined report_taskkill_critical echo.%report_taskkill_critical%
	if defined report_vssadmin echo.%report_vssadmin%
	if defined report_psexec echo.%report_psexec%
	if defined extra_info (
		echo.
		echo Extra information:
		echo.
		if defined bfp echo File packed using Batch File Packer ^(BFP^)
		if defined in2batch echo File packed using In2Batch
		if defined obfuscated echo Batch file obfuscated using %obfc% hexadecimal characters
		echo.
	)
	echo.
	echo Ratio: %ratio%/20
	echo.
	<nul set /p "=Veridict: "
)
:: 12/20+ considered malicious
::set ratio=12
::echo on
for %%A in (bcdedit delete http_ftp mimikatz ping icacls schtasks netsh taskkill taskkill_critical vssadmin psexec) do if defined report_%%A set ai_%%A=1

	
if %ratio% geq 18 (
	echo.!string[severe]!
	exit /b %ratio%
)
if %ratio% leq 17 if %ratio% geq 10 (
	echo.!string[malware]!
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
:: In case of failure, exit with error code 1
exit 1

:help
echo.
echo Batch Antivirus - DeepScan
echo.
echo Syntax:
echo.
echo DeepScan ^<filename^>
echo.
echo Example:
echo.
echo DeepScan script.bat
echo.
echo Will return the malware detection code (0 means safe, 20 means severe malware)
echo and will print report
echo.
echo Copyright (c) 2020 anic17 Software
exit/B
