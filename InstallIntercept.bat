::BAV_:git@github.com:anic17/Batch-Antivirus.git
@echo off
setlocal EnableDelayedExpansion
title Batch Antivirus Malware Interception
pushd "%~dp0"
net session > nul 2>&1 || (
	echo.Please run this script as an administrator.
	pause>nul
	exit /b
)
echo.Batch Antivirus Malware Interception
echo.
echo.By enabling this, Batch Antivirus will overwrite the file associations for all the executable files.
echo.While this can provide better protection, it can also cause issues. Use it at your own risk^!
echo.
echo.Backups of the current file associations will be saved in 'RegBackup' directory.
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
md "%~dp0RegBackup" > nul 2>&1
for %%A in ("batfile" "cmdfile" "exefile" "VBSFile" "VBEfile" "JSFile" "JSEfile" "comfile" "mscfile" "WSFFile" "WSHFile") do (
	reg export "HKEY_CLASSES_ROOT\%%~A\shell\open\command" "RegBackup\%%~A_backup.reg" /y > nul 2>&1 && (
		echo Backup saved ^(%%~A^)
		reg add "HKEY_CLASSES_ROOT\%%~A\shell\open\command" /t REG_SZ /d "\"%~dp0ScanIntercept.bat\" \"%%1\" %%*" /f && (
			echo Protection installed successfully for '%%~A'
		) || (
			echo Failed to install protection for '%%~A'
		)
	)
)
echo.Registry backups saved in "%~dp0RegBackup"
echo.
:quit
echo.Press any key to quit...
pause>nul
popd
endlocal
exit /b