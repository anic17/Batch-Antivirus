::BAV_:git@github.com:anic17/Batch-Antivirus.git
@echo off
setlocal EnableDelayedExpansion
set balloon_notification_timeout=100000
set "command_args=%*"
set "file=%~1"
for /f %%A in ('sha256 "!file!"') do call :scan %%A
exit /b

:scan
set "hash=%~1"
set "hash=!hash:~1!"
findstr /c:"!hash!" "%~dp0VirusDataBaseHash.bav" > nul 2>&1 || (
	!command_args!
	exit /b
)
for /f "tokens=1,2* delims=:" %%A in ('findstr /c:"%hash%" "%~dp0VirusDataBaseHash.bav"') do set "threat_name=%%B"

powershell [Reflection.Assembly]::LoadWithPartialName("""System.Windows.Forms""");$obj=New-Object Windows.Forms.NotifyIcon;$obj.Icon = [drawing.icon]::ExtractAssociatedIcon($PSHOME + """\powershell.exe""");$obj.Visible = $True;$obj.ShowBalloonTip(%balloon_notification_timeout%, """Batch Antivirus""","""Threats found: %threat_name%""",2)>nul
goto quit