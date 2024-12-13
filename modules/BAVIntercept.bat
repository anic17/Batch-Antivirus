::BAV_:git@github.com:anic17/Batch-Antivirus.git
@echo off
setlocal EnableDelayedExpansion
if exist "%~dp0Data\FileIntercept.ini" set installed=1

if "%~1" neq "" (
	if "!installed!" equ "1" goto scanintercept
	echo.Batch Antivirus Malware Interception is not enabled. If you wish to install it,
	echo.please run this file without arguments with adminstrative privileges.
	exit /b
)
title Batch Antivirus Malware Interception

pushd "%~dp0"
:menu
cls
if "!installed!" equ "1" (
	echo.Batch Antivirus Malware Interception
	echo.
	echo.File interception is enabled, do you wish to disable it? ^(y/n^)
	choice /c:YN /n
	if !errorlevel!==1 goto disableintercept
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
echo.These changes can be reverted at any moment by running this utility again.
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
reg add HKEY_CLASSES_ROOT\*\shell\BatchAntivirus /t REG_SZ /v Icon /d "\"%~dp0Data\resources\icon.ico\"" /f > nul 2>&1 
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

:disableintercept
echo.
echo.Disabling script made by BatchDebug ^(https://github.com/BatchDebug/BavRestoreTool^)
echo.
echo.1^) Restore all file extensions (recommended)
echo.2^) Restore a single file extension

choice /c:12 /N
if errorlevel 1 goto restoreall
if errorlevel 2 goto restoresingle 
goto quit

:restoreall
echo Restoring all file associations...
set "logfile=%~dp0Data\RestoreLog.txt"
echo.Creating restoration log at '!logfile!'
echo.
echo Batch Antivirus Interception Restoration Log - %date% %time% >> "!logfile!"
echo ============================== >> "!logfile!"
for %%A in ("batfile" "cmdfile" "exefile" "VBSFile" "VBEfile" "JSFile" "JSEfile" "comfile" "mscfile" "WSFFile" "WSHFile") do (
	if exist "%~dp0RegBackup\%%~A_backup.reg" (
		reg import "%~dp0RegBackup\%%~A_backup.reg" >nul 2>&1
		if !errorlevel! equ 0 (
			echo Successfully restored '%%~A' >> "!logfile!"
			echo Successfully restored '%%~A'
		) else (
			echo Failed to restore '%%~A' >> "!logfile!"
			echo Failed to restore '%%~A'
		)
	) else (
		echo No backup found for '%%~A'. Skipping. >> "!logfile!"
		echo No backup found for '%%~A'. Skipping.
	)
)
	
if exist "%~dp0RegBackup\shell_backup.reg" (
	reg import "%~dp0RegBackup\shell_backup.reg" >nul 2>&1
	if !errorlevel! equ 0 (
		echo Successfully restored context menu backup. >> "!logfile!"
		echo Successfully restored context menu backup.
	) else (
		echo Failed to restore context menu backup. >> "!logfile!"
		echo Failed to restore context menu backup.
	)
) else (
	echo No context menu backup found. >> "!logfile!"
	echo No context menu backup found.
)
if exist "%~dp0Data\FileIntercept.ini" (
	echo.Deleting '%~dp0Data\FileIntercept.ini' >> "!logfile!"
	echo.Deleting '%~dp0Data\FileIntercept.ini'
	del "%~dp0Data\FileIntercept.ini" /q > nul 2>&1
)
goto quit

:restoresingle
cls
echo.Batch Antivirus Malware Interception
echo.
echo Select file type to restore:
echo.
echo 1. .bat (batfile)
echo 2. .cmd (cmdfile)
echo 3. .exe (exefile)
echo 4. .vbs (VBSFile)
echo 5. .vbe (VBEfile)
echo 6. .js  (JSFile)
echo 7. .jse (JSEfile)
echo 8. .com (comfile)
echo 9. .msc (mscfile)
echo 10. .wsf (WSFFile)
echo 11. .wsh (WSHFile)
echo 12. Return to the main menu
echo.
set /p filetype="Choose a file type to restore (1-11): "

:: Define the file type based on user input
set "fileext="
if "!filetype!"=="1" set "fileext=batfile"
if "!filetype!"=="2" set "fileext=cmdfile"
if "!filetype!"=="3" set "fileext=exefile"
if "!filetype!"=="4" set "fileext=VBSFile"
if "!filetype!"=="5" set "fileext=VBEfile"
if "!filetype!"=="6" set "fileext=JSFile"
if "!filetype!"=="7" set "fileext=JSEfile"
if "!filetype!"=="8" set "fileext=comfile"
if "!filetype!"=="9" set "fileext=mscfile"
if "!filetype!"=="10" set "fileext=WSFFile"
if "!filetype!"=="11" set "fileext=WSHFile"
if "!filetype!"=="12" goto :menu

if defined fileext (
	echo.
    echo Restoring backup for '!fileext!'...
    if exist "%~dp0RegBackup\!fileext!_backup.reg" (
        reg import "%~dp0RegBackup\!fileext!_backup.reg" >nul 2>&1
        if !errorLevel! equ 0 (
            echo Successfully restored '!fileext!'.
        ) else (
            echo Failed to restore '!fileext!'. Please check the backup file.
        )
    ) else (
        echo No backup found for '!fileext!'. Skipping.
    )
    pause
) else (
    echo Invalid choice.
)
echo.
echo.Press any key to return to the main menu...
pause>nul
goto menu




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
if not defined DetectionMaxRatio set DetectionMaxRatio=100
call "%~dp0BAVConfig.bat" --bav-itcp
echo.Malware found!: !file! (^Detection ratio: !DetectionMaxRatio!/100^)
pause>nul
exit /b 0