@echo off
<nul set /p "=Checking Batch Antivirus file integrity... "
set skip=0
if "%~1"=="--skip" set skip=1
for %%A in (
	"%~dp0BAV.bat"
	"%~dp0BAVAutorun.bat"
	"%~dp0BAVConfig.bat"
	"%~dp0BAVDetail.bat"
	"%~dp0BAVStatus.bat"
	"%~dp0BAVUpdate.bat"
	"%~dp0DeepScan.bat"
	"%~dp0Quarantine.bat"
	"%~dp0RealTimeProtection.bat"
	"%~dp0BAVIntercept.bat"
	"%~dp0USBCleaner.bat"
	"%~dp0USBScan.bat"
	"%~dp0VirusDataBaseHash.bav"
	"%~dp0VirusDataBaseIP.bav"
	"%~dp0gethex.exe"
	"%~dp0sha256.exe"
	"%~dp0waitdirchange.exe"
) do (
	if not exist "%%~A" (
		echo.
		echo.Corrupt Batch Antivirus installation. Please redownload it from the official GitHub.
		echo.https://github.com/anic17/Batch-Antivirus
		echo.
		echo.Missing file: '%%~nxA'
		pause>nul
		endlocal
		exit /b 1
	)
)
echo.done
if "%skip%"=="0" (
	pause>nul
)
exit /b 0
