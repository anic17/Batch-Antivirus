::BAV_:git@github.com:anic17/Batch-Antivirus.git
@echo off
setlocal EnableDelayedExpansion
title Batch Antivirus Installer
call :banner
echo.This program will guide you installing Batch Antivirus in your system to improve your security 
echo.against viruses and malware and improving your overall system stability
echo.
for /f %%# in ('copy /Z "%~dpf0" nul') do set "CR=%%#"
pushd "%~dp0\modules"
call "%~dp0BAVStatus.bat" --skip-bav || exit /b

@echo off

echo.
net session > nul 2>&1 || (
	echo.To install Batch Antivirus in your system, administrator permissions are required.
	goto quit
)
echo.
echo.Are you sure you want to install Batch Antivirus? (y/n)
choice /c:YN /n > nul

if errorlevel 1 goto installopts
if errorlevel 2 goto quit
echo.Unknown option
goto quit

:installopts
echo.
echo.There are two possible installation options.
echo. - Option 1: Current user (%username%)
echo. - Option 2: All users (recommended)
choice /c:12 /n >nul
set programdata_smenu=0
if errorlevel 1 (set "installpath=!HOMEDRIVE!\Batch Antivirus" & set programdata_smenu=1)
if errorlevel 2 set "installpath=!LOCALAPPDATA!\Batch Antivirus"
if "!installpath!"=="" goto quit
:installpath
cls
call :banner
echo.Install path:
echo.!installpath!
echo.
echo.Are you sure you want to install Batch Antivirus to this path? (y/n)
choice /c:YN /n > nul
if errorlevel 1 goto install
if errorlevel 2 goto quit
:install
echo.
echo Installing Batch Antivirus...
echo.
<nul set /p "=Create installation directory... "
md "!installpath!\modules\Data\Quarantine" > nul 2>&1 && (
		echo.[OK]
) || (
	echo.[ERROR]
	goto failed
)

<nul set /p "=Getting install file paths... "
for /f "tokens=" %%X in ('findstr /rc:"\"%%~dp0.*\.[a-z][a-z][a-z]\"" "%~dp0\BAVstatus.bat"') do (
	echo.%%X
)


echo.Do you want to create a Start Menu shortcut? ^(y/n^)
choice /c:YN /n > nul
if errorlevel 1 (
	set "shortcut_path=!appdata!"
	if "!programdata_smenu!"=="1" set "shortcut_path=!programdata!"
	
	set "shortcut_path=!shortcut_path!\Microsoft\Windows\Start Menu\Programs"
	md "!shortcut_path!"
	powershell -ExecutionPolicy Unrestricted -Command "$s=(New-Object -COM WScript.Shell).CreateShortcut('!shortcut_path!\Batch Antivirus.lnk');$s.TargetPath='!installpath!\BAV.bat';$s.IconLocation = '!installpath!\modules\Data\BAV.ico';$s.Save()"


pushd "!installpath!"

goto success

:success
echo.Batch Antivirus has been successfully installed in your system.


:failed
echo.
echo.Failed to install Batch Antivirus^^! If the problem persists, contact the author ^(anic17^) on GitHub


:quit
echo.Press any key to quit...
popd
pause>nul
endlocal
exit /b !errorlevel!

:banner
echo.Batch Antivirus Installer
echo.