::BAV_:git@github.com:anic17/Batch-Antivirus.git
@echo off

for /f "tokens=1-3 delims=/" %%A in ('date /t') do set "date_=%%A%%B%%C"

set "date_=%date_:-=%"
set "date_=%date_: =%"

:: ===== Do not modify anything above this line =====




:: ===== Batch Antivirus settings start here =====
::
:: Blindly changing settings may leave your system unprotected and vulnerable
:: Do not change the parameters you do not fully understand
::

:: Graphical settings
set bav_rt_title=Batch Antivirus Real-Time Protection
set display_eng_start=1
set display_title=1
set show_balloon=1
set malware_message=1
set balloon_notification_timeout=100000

set background_process=1


:: Log scanned/detected files
set log_scanned=0
set log_detected=1
set stdout_log_scanned=0
set stdout_log_detected=1
set "logfile=%~dp0Data\Logfile_%date_%.log"	

:: Engine scanning settings

set dir_scan_freq=15

:: Quarantine/delete (Not recommended to change)
set nodelete=0
set noquarantine=0

:: IP protection
set timeout_ip=2
set kill_process_ip=1

:: Engine protection
set kill_protection=0

:: Kill protection monitor file
set "kp_file=BAV_kp.vbs"

:: Path check file
set "chkss_pth=sec_kp_bav_rtp.tmp"


:: Display CPU overheating and low disk space warnings
set display_overheat=1
set display_lowdisk=1

:: Check for updates at every start (not recommended to disable)
set check_updates=1

:: ===== Batch Antivirus settings end here =====







:: ===== Message when open from Windows Explorer, do not modify anything below this line =====

if "%~1"=="" (
	for /f "tokens=2 delims= " %%A in ("%cmdcmdline%") do if /i "%%A"=="/c" (
		echo.To edit Batch Antivirus settings, please open this file in a text editor
		echo.
		echo.WARNING: Blindly changing settings might leave your system unprotected
		echo.         Change them at your own risk^^!
		pause>nul
		exit /b
	)
)



:: ===== End Batch Antivirus internal functions =====