@echo off
<nul set /p "=Verifying Batch Antivirus file integrity... "
set skip=0
set skip-bav=0
if "%~1"=="--skip" set skip=1
if "%~1"=="--skip-bav" (
	set skip=1
	set skip-bav=1
)
for %%A in (
	"%~dp0BAVDisk.bat"
	"%~dp0BAVAutorun.bat"
	"%~dp0BAVConfig.bat"
	"%~dp0BAVDetail.bat"
	"%~dp0BAVDisk.bat"
	"%~dp0BAVStatus.bat"
	"%~dp0BAVUpdate.bat"
	"%~dp0DeepScan.bat"
	"%~dp0Quarantine.bat"
	"%~dp0RealTimeProtection.bat"
	"%~dp0BAVIntercept.bat"
	"%~dp0USBScan.bat"
	"%~dp0VirusDataBaseHash.bav"
	"%~dp0VirusDataBaseIP.bav"
	"%~dp0gethex.exe"
	"%~dp0sha256.exe"
	"%~dp0waitdirchange.exe"
) do (
	if not exist "%%~A" (
		if "!skip_bav!" equ "1" (
			if /i "%%~nxA" neq "BAV.bat" (
				call :corrupt "%%~nxA"
			)
		) else (
			call :corrupt "%%~nxA"
		)
	)
)
echo.done
if "%skip%"=="0" (
	pause>nul
)
:quit
exit /b 0

:corrupt
echo.
echo.Corrupt Batch Antivirus installation. Please redownload it from the official GitHub.
echo.https://github.com/anic17/Batch-Antivirus
echo.
echo.Missing file: '%~1'
pause>nul
endlocal
exit