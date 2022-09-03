::BAV_:git@github.com:anic17/Batch-Antivirus.git
@echo off
title Batch Antivirus Quarantine
setlocal EnableDelayedExpansion
pushd "%~dp0"
if not exist "Data\Quarantine" (
	echo.No quarantine for Batch Antivirus found
	goto quit
)
echo.Querying quarantine...	
echo.
echo.------------------------------------------------

for /f "delims=" %%A in ('dir /s /b "%~dp0Data\Quarantine"') do (

	if "%%~nxA"=="name" (
		for /f "usebackq delims=" %%B in ("%%~fA") do (
			echo.Original name:  %%~nxB
			echo.Original path:  %%~fB
			if exist "%%~dpAdetection" (
				set /p detection_name=<"%%~dpAdetection"
					echo.Detection name: !detection_name!
				)
			)
		echo.------------------------------------------------
			
			
		)
	)
)
goto quit

:quit
echo.
echo.Press any key to quit...
pause>nul
popd
exit /b