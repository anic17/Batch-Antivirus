::BAV_:git@github.com:anic17/Batch-Antivirus.git
@echo off
setlocal EnableDelayedExpansion

if "%~1" neq "" goto scanintercept
title Batch Antivirus Malware Interception

pushd "%~dp0"
if exist "%~dp0Data\FileIntercept.ini" (
	echo.File interception is already enabled.
	echo.
	goto quit
)

net session > nul 2>&1 || (
	echo.This script intercepts the file associations executable files
	echo.If you wish to do so, please run this script as administrator.
	echo.
	echo.WARNING: While this can provide better protection, it can also cause issues.
	echo.         Use it at your own risk^^!
	pause>nul
	exit /b
)
echo.Batch Antivirus Malware Interception
echo.
echo.By enabling this, Batch Antivirus will overwrite the file associations for all the executable files.
echo.A context menu option "Scan with Batch Antivirus" will also be added.
echo.Backups of the current file associations will be saved in 'RegBackup' directory.
echo.
echo.WARNING: While this can provide better protection, it can also cause issues. 
echo.The creator is not responsible for any damages this feature can cause. Use it at your own risk^^!
echo.
echo.Are you sure you want to enable file association interception? (y/n)
choice /c:YN /n
if !errorlevel!==1 goto installintercept
if !errorlevel!==2 (
	echo.Operation aborted.
	echo.
	goto quit
)
goto quit
:installintercept
echo.FileIntercept=1 > "%~dp0Data\FileIntercept.ini"
md "%~dp0RegBackup" > nul 2>&1
for %%A in ("batfile" "cmdfile" "exefile" "VBSFile" "VBEfile" "JSFile" "JSEfile" "comfile" "mscfile" "WSFFile" "WSHFile") do (
	reg export "HKEY_CLASSES_ROOT\%%~A\shell\open\command" "RegBackup\%%~A_backup.reg" /y > nul 2>&1 && (
		<nul set /p "=Backup saved (%%~A). "
		reg add "HKEY_CLASSES_ROOT\%%~A\shell\open\command" /t REG_SZ /d "\"%~f0\" \"%%1\" %%*" /f > nul && (
			echo Protection installed successfully for '%%~A'
		) || (
			echo Failed to install protection for '%%~A'
		)
	)
)
<nul set /p "=Adding Batch Antivirus to context menu... "
reg export "HKEY_CLASSES_ROOT\*\shell\" "%~dp0\RegBackup\shell_backup.reg" /y > nul 2>&1
reg add HKEY_CLASSES_ROOT\*\shell\BatchAntivirus\command /t REG_SZ /d "\"%~dp0DeepScan.bat\" \"%%1\" & cmd.exe /c pause" /f > nul 2>&1 
reg add HKEY_CLASSES_ROOT\*\shell\BatchAntivirus /t REG_SZ /v Icon /d "\"%~dp0Data\icon.ico\"" /f > nul 2>&1 
reg add HKEY_CLASSES_ROOT\*\shell\BatchAntivirus /t REG_SZ /d "Scan with Batch Antivirus" /f > nul 2>&1 && (
	echo.Done. 
) || (
	echo.Failed to add Batch Antivirus to context menu.
)
echo.

echo.Registry backups saved in "%~dp0RegBackup"
echo.
:quit
echo.Press any key to quit...
pause>nul
popd
endlocal
exit /b

:scanintercept

if "%~f0"=="%~f1" (
	echo.Cannot run this program recursively.
	pause>nul
	exit /b 0
)
set balloon_notification_timeout=100000
set "command_args=%2 %3 %4 %5 %6 %7 %8 %9"
set "file=%~1"
call "%~dp0DeepScan.bat" "!file!" --verbose --novirustotal
set ret_deepscan=%errorlevel%
if %ret_deepscan% lss 20 (
	"!file!" !command_args!
	exit /b %errorlevel%
)
call "%~dp0BAVConfig.bat"
echo.Malware found: !file! (Detection ratio: !DetectionMaxRatio!/100)
pause>nul
exit /b 0