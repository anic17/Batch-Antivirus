::BAV_:git@github.com:anic17/Batch-Antivirus.git
@echo off
setlocal EnableDelayedExpansion
cd /d "%~dp0"
call "%~dp0BAVStatus.bat" --skip
if "!errorlevel!"=="1" exit /b

:menu
cls
title Batch Antivirus Website Blocker
echo.Batch Antivirus Website Blocker
echo.


echo.This module will help you block the websites you want.
echo.
echo.Please choose an option:
echo.1^) Block new website
echo.2^) Unblock a previously blocked website
choice /c:12 /n > nul
if "!errorlevel!"=="1" goto blockwebsite
if "!errorlevel!"=="2" goto unblockwebsite
echo.
echo.Invalid choice. Press any key to return to the menu...
pause>nul
goto menu

:blockwebsite
echo.
set /p "url=URL or IP to block: "
echo.
set "url=!url:http://=!"
set "url=!url:https://=!"
(<nul set /p "=!url!" | findstr /rc:"[0-9].*\.[0-9].*\.[0-9].*[0-9].*" /b) > nul 2>&1 && (
	call :checkifblocked "!url!" "!url!"
	goto blockip
)

<nul set /p "=Getting IP address of !url!... "
for /f "tokens=1* delims=[" %%A in ('ping !url! ^| findstr /rc:"\[[0-9].*\.[0-9].*\.[0-9].*[0-9].*\]"') do for /f "tokens=1 delims=]" %%X in ("%%B") do set ip=%%X
if "!ip!"=="" (
	echo.Failed to get website IP
	goto quit
)
echo.done [!ip!]
call :checkifblocked "!ip!" "!url!"


:blockip
echo.Blocking !url!
echo.!ip! !url!>> "%~dp0VirusDataBaseIP.bav"
findstr /c:"!ip! !url!" "%~dp0VirusDataBaseIP.bav" > nul 2>&1 && (
	echo.Successfully blocked !url!
) || (
	echo.Failed to block !url!
)
goto quit

:unblockwebsite
echo.
set /p "url=URL or IP to unblock: "
set "url=!url:http://=!"
set "url=!url:https://=!"
set is_ip=0
set "search_string= !url!"
(<nul set /p "=!url!" | findstr /rc:"[0-9].*\.[0-9].*\.[0-9].*[0-9].*" /b) > nul 2>&1 && (
	set is_ip=1
)
if "!is_ip!"=="1" (
	findstr /bc:"!url! !url!" "%~dp0VirusDataBaseIP.bav" > nul 2>&1 || (
		echo.!url! is not blocked
		goto quit
	)
	set "search_string=!url! !url"
) else (
	findstr /c:" !url!" /e "%~dp0VirusDataBaseIP.bav" > nul 2>&1 || (
		echo.!url! is not blocked
		goto quit
	)
)
findstr /vc:"!search_string!" "%~dp0VirusDataBaseIP.bav" > "%~dp0VDBIP_Temp.bav"
if exist "%~dp0VDBIP_Temp.bav" (
	move /y "%~dp0VirusDataBaseIP.bav" "%TMP%" > nul 2>&1
	move "%~dp0VDBIP_Temp.bav" "%~dp0VirusDataBaseIP.bav"
)
echo.Successfully unblocked !url!
goto quit


:quit
echo.
echo Press any key to quit...
pause>nul
endlocal
exit 0

:checkifblocked <ip> <url>
findstr /c:"%~1" /c:"%~2" "%~dp0VirusDataBaseIP.bav" > nul 2>&1 && (
	echo.!url! is already blocked
	goto quit
)
exit /b