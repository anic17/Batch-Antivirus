::BAV_:git@github.com:anic17/Batch-Antivirus.git
@echo off
setlocal EnableDelayedExpansion
pushd "%~dp0"
call "%~dp0BAVStatus.bat" --skip
if "!errorlevel!"=="1" exit /b

:menu
cls
title Batch Antivirus Website Blocker
echo.Batch Antivirus Website Blocker
echo.
echo.This module will help you block any websites when real-time protection is running
echo.
echo.Please choose an option:
echo.1^) Block new website
echo.2^) Unblock a previously blocked website
echo.3^) View blocked websites
echo.
echo.q^) Quit
choice /c:123q /n
if "!errorlevel!"=="1" goto blockwebsite
if "!errorlevel!"=="2" goto unblockwebsite
if "!errorlevel!"=="3" goto viewwebsites
if "!errorlevel!"=="4" (
	popd
	endlocal
	exit /b
)
echo.
echo.Invalid choice. Press any key to return to the menu...
pause>nul
goto menu

:blockwebsite
echo.
set url=
set /p "url=URL or IP to block: "
echo.

if "!url!"=="" (
	echo.No URL specified^^!
	goto pausemenu
)
set "url=!url:http://=!"
set "url=!url:https://=!"

set arrsize=0

(<nul set /p "=!url!" | findstr /rc:"[0-9].*\.[0-9].*\.[0-9].*[0-9].*" /b) > nul 2>&1 && (
	call :checkifblocked "!url!" "!url!"
	set ip[0]=!url!
	goto blockip
)

<nul set /p "=Getting IP address of !url!... "

call :getip !url!
set normal_url=
call :getip www.!url!

if "!arrsize!"=="0" (
	echo.
	echo.Failed to get the website IP
	goto pausemenu
)


echo.done
call :checkifblocked "!ip[0]!" "!url!"

:blockip
echo.Blocking !url!
if !arrsize! gtr 0 set /a arrsize-=1
for /l %%A in (0,1,!arrsize!) do (
	echo.>> "%~dp0Data\BlockedSites.bav"
	<nul set /p "=!ip[%%A]! !url!">> "%~dp0Data\BlockedSites.bav"
)
findstr /c:"!ip[0]! !url!" "%~dp0Data\BlockedSites.bav" > nul 2>&1 && (
	echo.Successfully blocked !url!
) || (
	echo.Failed to block !url!
)
for /l %%A in (0,1,!arrsize!) do (
	set ip[%%A]=
)
set arrsize=0
goto pausemenu

:unblockwebsite
echo.
set url=
set /p "url=URL or IP to unblock: "
echo.
if "!url!"=="" (
	echo.No URL specified
	goto pausemenu
)
set "url=!url:http://=!"
set "url=!url:https://=!"
set is_ip=0
set "search_string= !url!"
(<nul set /p "=!url!" | findstr /rc:"[0-9].*\.[0-9].*\.[0-9].*[0-9].*" /b) > nul 2>&1 && (
	set is_ip=1
)
if "!is_ip!"=="1" (
	findstr /bc:"!url! !url!" "%~dp0Data\BlockedSites.bav" > nul 2>&1 || (
		echo.!url! is not blocked
		goto pausemenu
	)
	set "search_string=!url! !url"
) else (
	findstr /c:" !url!" /e "%~dp0Data\BlockedSites.bav" > nul 2>&1 || (
		echo.!url! is not blocked
		goto pausemenu
	)
)
findstr /vc:"!search_string!" "%~dp0Data\BlockedSites.bav" > "%~dp0BAV_BS_Temp.bav"
if exist "%~dp0BAV_BS_Temp.bav" (
	move /y "%~dp0Data\BlockedSites.bav" "%TMP%" > nul 2>&1
	move "%~dp0BAV_BS_Temp.bav" "%~dp0Data\BlockedSites.bav" > nul 2>&1
	echo.Successfully unblocked !url!
) else (
	echo.Failed to unblock !url!
)
goto pausemenu


:viewwebsites
echo.
echo.Blocked websites by Batch Antivirus:
echo.
set "rfname=%TMP%\bav_vbw!random!!random!.lst"
if exist "!rfname!" del "!rfname!" /q /f > nul 2>&1
<nul set /p "=" > "!rfname!"
for /f "tokens=2 delims= " %%X in ('findstr /r /c:"[0-9] .*\." "%~dp0Data\BlockedSites.bav"') do echo.%%X >> "!rfname!"
for /f "delims=" %%X in ("!rfname!") do (
	if "%%~zX"=="0" (
		echo.No blocked websites found
	) else (
		sort /uniq "!rfname!"
	)
)
del "!rfname!" /q /f > nul 2>&1
goto pausemenu


:pausemenu
echo.
echo Press any key to return to the main menu...
pause>nul
goto menu

:checkifblocked <ip> <url>
findstr /c:"%~1" /c:"%~2" "%~dp0Data\BlockedSites.bav" > nul 2>&1 && (
	echo.!url! is already blocked
	goto pausemenu
)
exit /b


:getip <url>
set cnt=0
for /f "tokens=1*" %%A in ('nslookup "%~1" 2^>nul ^| findstr /rc:"[0-9].*\.[0-9].*\.[0-9].*[0-9].*"') do (
	for /f "tokens=2 delims=:" %%X in ('^<nul set /p "=%%A %%B"') do (
		if "!cnt!" neq "0" (
			set "ipx=%%X"
			set "ipx=!ipx:.=-!"
			if "%%X" neq "!ipx!"  (
				set "ip_nows=%%X"
				if "!ip_nows!" neq "127.0.0.1" (
					set "ip_nows=!ip_nows: =!"
					set "ip[!arrsize!]=!ip_nows!"
					set /a arrsize+=1
				)
			)
		)
		set /a cnt+=1
	)
	set "ipn=%%A"
	set "ipn=!ipn:.=-!"
	if "%%A" neq "!ipn!"  (
		set "ip[!arrsize!]=%%A"
		set /a arrsize+=1
	)
)