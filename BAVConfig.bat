::BAV_:git@github.com:anic17/Batch-Antivirus.git
@echo off
for /f "tokens=1-3 delims=/" %%A in ('date /t') do set "date_=%%A%%B%%C"
set "date_=!date_:-=!"
::Start settings
::
:: Don't mess up with settings, it might leave your system unprotected
::
::

:: Graphical settings
set bav_rt_title=Batch Antivirus Real-Time Protection
set display_eng_start=1
set display_title=1
set showballoon=1
set malware_message=1
set balloon_notification_timeout=100000

set background_process=1


:: Log scanned/detected files
set log_scanned=0
set log_detected=1
set stdout_log_scanned=0
set stdout_log_detected=1
set "logfile="%~dp0Batch-Antivirus_!date_!""	

:: Engine scanning settings
set root_dir=%SystemDrive%\
set dir_scan_freq=3

:: Quarantine/delete (Not recommended to change)
set nodelete=0
set noquarantine=0

:: IP protection
set timeout_ip=2
set kill_process_ip=1

:: Engine protection
set kill_protection=0
set "kp_file=BAV_kp.vbs"

set "chkss_pth=sec_kp_bav_rtp.tmp"
