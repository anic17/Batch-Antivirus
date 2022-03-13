@echo off
reg export "HKEY_CLASSES_ROOT\cmdfile\shell\open\command" cmdfile_backup.reg /y > nul 2>&1 && echo Backup saved
reg add "HKEY_CLASSES_ROOT\cmdfile\shell\open\command" /d "\"%~dp0ScanIntercept.bat\" \"%%1\" %%*" /f > nul 2>&1 && (echo Protection installed successfully) || (echo Failed to install protection)
pause
exit /b