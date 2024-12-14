::BAV_:git@github.com:anic17/Batch-Antivirus.git
@echo off

if "%~f1"=="%~f0" echo Safe file ^(Batch Antivirus module^). && exit /b 0
if /i "%~1"=="--help" goto help

for %%A in (
	"%~dp0VirusDataBaseHash.bav"
	"%~dp0gethex.exe"
	"%~dp0sha256.exe"
) do (
	if not exist "%%~A" (
		echo.Engine cannot start^^!
		echo.Missing file: "%%~A"
		exit /b
	)
)

set MalwareScore=100

setlocal EnableDelayedExpansion

set /p bav_version=<"%~dp0VirusDataBaseHash.bav"
set "bav_version=!bav_version::=!"

if "%~1"=="" (
	echo.Required parameter missing. Try with '%~n0 --help'.
	endlocal | set MalwareScore=%MalwareScore%
	popd
	exit /b 1
)

set report=1
set verbose=0
set ratio=0


for %%A in (
	"ignoredb"
	"noreport"
	"novirustotal"
	"verbose"
) do (
	rem '--ignoredb' and '--noreport' flags
	if "%~2"=="--%%~A" set "%%~A=1"
	if "%~3"=="--%%~A" set "%%~A=1"
	if "%~4"=="--%%~A" set "%%~A=1"
	if "%~5"=="--%%~A" set "%%~A=1"
	if "%~6"=="--%%~A" set "%%~A=1"
)
:: Checking if file exists has to be done before initializing
set "filescan=%~f1"
if not exist "!filescan!" (
	echo.Could not find '!filescan!' 1>&2
	endlocal | set MalwareScore=0
	popd
	exit /b -1
)
pushd "%~dp0"

if "%noreport%"=="1" set report=0


if "!verbose!"=="0" (
	echo.
	for /f %%A in ('copy /Z "%~dpf0" nul') do set "CR=%%A"
	<nul set /p "=Scanning file... "
)

:startscan

:: Get hash
for /f %%A in ('sha256 "!filescan!" 2^>nul') do (
	set "hash=%%A"
	set "hash=!hash:\=!"
)
if not defined hash (
	echo.Retrieving hash with CertUtil...
	for /f %%A in ('certutil -hashfile "!filescan!" SHA256 ^| findstr /vc:"h"') do set "hash=%%~A"
)
if "!ignoredb!" neq "1" (
	for /f "tokens=1* delims=:" %%a in ('findstr /c:"%hash%" "%~dp0VirusDataBaseHash.bav"') do (
		if "%%a"=="%hash%" (
			if "!verbose!"=="0" (
				echo.!cr!Scan finished.  
				echo.Malware found: !filescan! ^| %%b
				set "detection=%%b"
				
			)
			popd
			exit /b !MalwareScore!
		)
	)
)

set head=
set obfuscated=
set bfp=



for /f "delims=" %%A in ('gethex "!filescan!" 48') do set "hexhead=%%A"


if "%hexhead%"=="" (
	if "!verbose!"=="0" (
		echo.!cr!Scan finished.  
		echo.
		echo Safe file ^(zero-byte file^).
	)
	exit /b 0
)

:: Whitelist the file if it's a BAV module
if "!hexhead!"=="3a3a4241565f3a676974406769746875622e636f6d3a616e696331372f42617463682d416e746976697275732e676974" (
	if "!verbose!"=="0" (
		echo.!cr!Scan finished.  
		echo.
		echo Safe file ^(Batch Antivirus module^).
	)
	endlocal | set MalwareScore=%MalwareScore%
	popd
	exit /b 0
)

if "!novirustotal!" neq "1" (
	set "ak=4e3202fdbe953d628f650229af%=616e69633137%5b3eb49cd46b2d3bfe5546ae3c5fa48b554e0c"
	curl "https://www.virustotal.com/api/v3/files/!hash!" --header "x-apikey: !ak!" --output "%TMP%\VTAPIQuery.tmp" --silent && (
		findstr /c:"QuotaExceededError" /c:"NotFound" /c:"WrongCredentialsError" /c:"NotAvailableYet" /c:"TooManyRequestsError" /c:"AuthenticationRequiredError" /c:"BadRequestError" "%TMP%\VTAPIQuery.tmp" > nul 2>&1 && (
			goto skipVT
		) || (
			for /f "tokens=2 delims=:" %%A in ('findstr /rc:"\"malicious\":.*," "%TMP%\VTAPIQuery.tmp"') do set "malicious=%%~A"
			for /f "tokens=2 delims=:" %%A in ('findstr /rc:"\"undetected\":.*" "%TMP%\VTAPIQuery.tmp"') do set "undetected=%%~A"
			for /f "tokens=2 delims=:" %%A in ('findstr /rc:"\"meaningful_name\":" "%TMP%\VTAPIQuery.tmp"') do set "meaningful_name=%%~A"
			
			set "undetected=!undetected:,=!"
			set "malicious=!malicious:,=!"
			set "meaningful_name=!meaningful_name:"=!"
			set "meaningful_name=!meaningful_name:,=!"
			for /f "usebackq tokens=*" %%X in (`echo.!meaningful_name!`) do set "meaningful_name=%%X"
			for /f "usebackq tokens=*" %%X in (`echo.!malicious!`) do set "malicious=%%X"
			set /a total=malicious + undetected
			if "!verbose!"=="0" (
				if defined malicious if "!total!" neq "0" (
					echo.
					echo.File '!filescan!' ^(aka '!meaningful_name!'^) has !malicious!/!total! VirusTotal detections.
				)
			)
		)
	)
)
:skipVT

for /f "delims=" %%A in ("!filescan!") do set "extension_arg1=%%~xA"



if /i "!extension_arg1!"==".bak" (
	call :remove_bak_extension "%~f1"
	set "extension_arg1=!_temp_bak_ext!"
)
if "!_unrec_file_format_bav!"=="1" exit /b && rem Unrecognized file, quit program
:: If file is a batch file, do a more in-depth scan
for %%A in (".cmd" ".bat" ".batch") do if /i "!extension_arg1!"=="%%~A" goto scanbatch

:gothead

set /p head=<"!filescan!"

set "head=!head:"=!"
set "head=!head:&=!"
set "head=!head:@=!"

for /f "tokens=1,* delims= " %%A in ("%head%") do set "head_tok1=%%A" && set "head_tok2=%%B"
set "head_tok1=!head_tok1:"=!"
set "head_tok2=!head_tok2:"=!"
set "head_tok1=!head_tok1:&=!"
set "head_tok2=!head_tok2:&=!"
set "head_tok1=!head_tok1:@=!"
set "head_tok2=!head_tok2:@=!"
:: Check for file MIME
if "%head%"==":BFP" set bfp=1
for %%A in ("echo" "if exist" "shift" "prompt" "title" "setlocal" "echo off" "echo on" "for" "::") do if "%%~A"=="%head%" set "mime=application/x-bat"
if "!mime!"=="application/x-bat" goto scanbatch
for %%A in ("#^!/usr/bin/python" "#^!/bin/python" "from" "import") do (
	for %%B in (".py" ".pyc") do if /i "%~x1"=="%%~B" set "mime=text/python"

	if "%%~A"=="!head_tok1!" set "mime=text/python"
)
if "%mime%"=="text/python" goto scanpython
for %%# in (".py" ".pyx". ".pyw" ".ipynb") do if "!extension_arg1!"=="%%~#" goto scanpython
if "!verbose!"=="0" (
	echo.
	echo.Incompatible scanning format. Binary files are not supported at the moment.
	echo.
	echo.Batch Antivirus can only heuristically analize batch files ^(.bat and .cmd^)
)
popd
exit /b -1




:: Scan batch programs (MIME application/x-bat)

:scanbatch

for /f "delims=" %%A in ("!filescan!") do set "fileext=%%~xA"

:: Check for In2Batch packed program
findstr /ic:"@if defined%=% _out %%%%~G" "!filescan!" > nul 2>&1 && (set "in2batch=1") || (set "in2batch=0")

:: Get program header to check for obfuscations & BFP packing
:: BFP download:
:: https://github.com/anic17/BFP
:: or https://github.com/anic17/Utilities

:: BFP header in hex
if "%hexhead:~0,8%"=="3a424650" set bfp=1

:: Windows binary files header in hex (MZ)
if "%hexhead:~0,4%"=="4d5a" (
	if "!verbose!"=="0" echo Binary files are not supported.
	exit /b -1
)


set "randx=!random!"
set "oldfn=!filescan!"
if "%BFP%"=="1" (
	rem Unpack file if packed with BFP
	del "%TMP%\bav_deepscan.bfp" /q /a > nul 2>&1
	del "%TMP%\bav_deepscan.b64" /q /a > nul 2>&1
	del "%TMP%\bav_deepscan.file*" /q /a > nul 2>&1
	findstr /vc:"echo." /c:"echo " /c:"for " /c:":" /c:"rem " /c:"certutil -" /c:")" /c:"del " /c:"expand" /c:"%%*" /vc:"erase" "!filescan!" | findstr /vc:"-" /c:"_" /c:"\\" /c:">" > "%TMP%\bav_deepscan.b64"

	certutil -decode -f "%TMP%\bav_deepscan.b64" "%TMP%\bav_deepscan.bfp"  > nul
	expand "%TMP%\bav_deepscan.bfp" "%TMP%\bav_deepscan.file!randx!!fileext!" > nul
	set "filescan=%TMP%\bav_deepscan.file!randx!!fileext!"
	del "%TMP%\bav_deepscan.bfp" /q /a > nul 2>&1
	del "%TMP%\bav_deepscan.b64" /q /a > nul 2>&1
	set "extra_info=BFP"
)

if "%in2batch%"=="1" (
	rem Unpack file if packed with In2Batch
	findstr /bic:"echo " "!filescan!" > "%TMP%\bav.deepscan.in2batch"
	del "%TMP%\bav_deepscan.file" /q /a > nul 2>&1
	for /f "usebackq tokens=2" %%X in ("%TMP%\bav.deepscan.in2batch") do for /f "eol=-" %%A in ("%%X") do (echo.%%A >> "%TMP%\bav.deepscan.in2batch.b64")
	certutil -decode -f "%TMP%\bav.deepscan.in2batch.b64" "%TMP%\bav_deepscan.file!randx!!fileext!" > nul 2>&1
	del "%TMP%\bav.deepscan.in2batch.b64" /q /a > nul 2>&1
	del "%TMP%\bav.deepscan.in2batch" /q /a > nul 2>&1
	set "filescan=%TMP%\bav_deepscan.file!randx!!fileext!"
	set "extra_info=In2Batch"

)
if defined extra_info (
	echo.Scanning !file!
	call :startscan
	set retv=!errorlevel!
	if "!retv!" neq 0 (
		echo. [Inside "!oldfn!"]
	)
	del "%TMP%\bav_deepscan.file!randx!!fileext!" /q /a > nul 2>&1
	set ratio=!retv!
	goto showreport
)

:: Different obfuscations (in hex): FE FF, FF FE, FF FE 00 00
if /i "%hexhead:~0,4%"=="feff" set "obfuscated=1"&set "obfc=FE FF"& set "extra_info=!obfc!"
if /i "%hexhead:~0,4%"=="fffe" set "obfuscated=1"&set "obfc=FF FE"& set "extra_info=!obfc!"
if /i "%hexhead:~0,8%"=="fffe0000" set "obfuscated=1"&set "obfc=FF FE 00 00"& set "extra_info=!obfc!"


set "htp="
set "htpk=ù8t¹s»C~NLhmpt»ÝA"
for %%B in (9=12;1,11;) do set "htp=!htp!!__htpk:~%%,1!"

:: Some other obfuscation for BAV to not detect itself
set ratio=0

set "pn=pin"
set "ic=icac"
set "sch=schta"
set "net=nets"
set "psx=psexe"
set "bcde=bcded"
set "vssa=vssadm"
set "re=eg"
set "sysnf=ysteminf"

set "curver=\\C%urrent!Version\\"
set "hklmregclass=H%KLM\\Software\\Cla!sses"
set "_mswin=Micr%osoft\\W!indows"
set "_strt=St!a%rt"
set "wdf=ws De"
set "ntivr=anti"

:: FINDSTR detection
:: Looks for patterns with regular expressions
:: Skips all lines starting by ECHO to avoid detecting URL printing as a direct request for example
:: 
:: Here we're checking for URL requests, pings, file deletion, process killing, self-copy, etc.

findstr /c:"%%=616e69633137%%" "!filescan!" > nul 2>&1 && goto whitelisted

findstr /ivc:"echo" /vc:"rem" "!filescan!" | findstr /i /c:"*\.*\.*\.*" /c:"!htp!://.*" /c:"www\..*" /c:"!htp!s://.*" /c:"ftp://.*" /c:"sftp://.*" /c:"curl* " /c:"wget" /c:"bitsadmin" /c:"certutil -urlcache" /c:"Invoke-WebRequest" /c:"object(\"Microsoft\.XML!htp!\")" /c:"ftp* -s" /c:"ftp\.exe" > nul 2>&1 && set /a ratio+=4 && set "report_http_ftp=Contacts an FTP server/makes an HTTP request (+4^)"

findstr /ric:"del X:\*" /c:"del %%HomeDrive%%\\Windows" /c:"erase %HomeDrive%" /c:"erase %%HomeDrive%%\\*" /c:"rmdir.*\\Windows\\" /c:"rd *" /c:"rd %HomeDrive%" /c:"rd %%HomeDrive%%\\.*" /c:"del.*VirusDataBaseHash" /c:"del.*VirusDataBaseIP" /c:"del.*deepscan" "!filescan!" > nul 2>&1 && set /a ratio+=15 && set "report_delete=Deletes system critical files (+15^)"
findstr /ic:"%pn%g " /c:"%pn%g.exe " /c:"tracert " /c:"tracert.exe" "!filescan!" >nul 2>&1 && set /a ratio+=2 && set "report_ping=Pings website/IP (+2^)"
findstr /ic:"nslookup " /c:"nslookup.exe" "!filescan!" >nul 2>&1 && set /a ratio+=5 && set "report_public_ip=Gets websites/computer's IP (+5^)"
findstr /ic:"%ic%ls " /c:"%ic%ls.exe " "!filescan!">nul 2>&1 && set /a ratio+=4 && set "report_icacls=Changes ACL of a file or directory (+4^)"
findstr /ic:"schta%=%sks " /c:"schtasks.exe " "!filescan!">nul 2>&1 && set /a ratio+=5 && set "report_schtasks=Modifies scheduled tasks (+5^)"
findstr /ic:"%net%h " /c:"%net%h." /c:"ipconfig " /c:"ipconfig." /c:"net." "!filescan!"	>nul 2>&1 && set /a ratio+=3 && set "report_netsh=Changes or views network configuration ^(+3^)"
findstr /ic:" advfirewall " /c:" firewall " /c:"ipconfig " /c:"ipconfig." /c:"net." "!filescan!" >nul 2>&1 && set /a ratio+=10 && set "report_firewall=Changes or views firewall configuration ^(+10^)"

findstr /ric:"net.* session" /ic:"cacls.* .*SYSTEM32" /c:"whoami.* /groups" /c:"sfc .*|.*find.*/SCANNOW" "!filescan!" >nul 2>&1 && set /a ratio+=3 && set "report_admin=Program checks for administrative privileges ^(+3^)"
findstr /ic:"s%sysnf%o" /ic:"s%sysnf%o.exe" "!filescan!" >nul 2>&1 && set /a ratio+=3 && set "report_systeminfo=Program retrieves potentially sensitive system information ^(+3^)"

findstr /ric:"\<reg\>" /c:"\<regedit\>" /c:"\<regedt32\>" /c:"\<regini\>" /c:"\<reg\>" /c:"\<regedit\>" /c:"\<regedt32\>" /c:"\<regini\>" "!filescan!" >nul 2>&1 && set /a ratio+=5 && set "report_reg=Modifies system registry (+5)"
findstr /ic:"\\Software\\Microsoft\\Windows\\CurrentVersion\\Run" /c:"\\Software\\Microsoft\\Windows\\CurrentVersion\\RunOnce" /c:"Microsoft\\Windows\\%_strt% Menu\\Programs\\Startup" "shell:startup" "!filescan!"  >nul 2>&1 && set /a ratio+=15 && set "report_startup=Program runs itself at system startup (+15^)"
findstr /ric:"add .HKCR\\.*" /c:"delete .*HKCR\\.*f" /c:"add .*!hklmregclass!\\.*" /c:"delete .*!hklmregclass!\\.*" /c:".*HKEY_CLASSES_ROOT\\.*" "!filescan!" >nul 2>&1 && set /a ratio+=9 && set "report_reg_hijack=Program hijacks file extensions (+9^)"


findstr /ric:"copy %%.*0 " /c:"xcopy.* %%~f0 " "!filescan!" > nul 2>&1 && set /a ratio+=12 && set "report_copyself=Program copies itself ^(+12^)"



findstr /ric:"psexec.*" /c:"%psx%c\." /c:"%psx%c64.*" /c:"%psx%c64\." "!filescan!" >nul 2>&1 && set /a ratio+=7 && set "report_psexec=Uses PSExec to run remote commands (+7)"

:: !mktz! is the encoded mimikatz string to avoid getting false detected by Windows Defender

findstr /ic:"m%=%imi%==%k%=%atz" "!filescan!" > nul 2>&1 && set /a ratio+=50 && set "report_mimikatz=Uses HackTool/Mimikatz  (+50^)"
findstr /ic:"%vssa%in " "!filescan!" > nul 2>&1 && set /a ratio+=15 && set "report_vssadmin=Uses VSSAdmin command to manage shadow copies (+15^)"
findstr /ic:"%bcde%it " "!filescan!" > nul 2>&1 && set /a ratio+=10 && set "report_bcdedit=Uses BCDEdit command to edit boot configuration data (+10^)"
findstr /ic:"taskkill /f /im " /c:"taskkill /im" /c:"taskkill /fi" /c:"taskkill /pid" /c:"taskkill /f" /c:"pskill " /c:"pskill.exe" /c:"pskill64 " /c:"tskill " /c:"tskill.exe" "!filescan!" > nul 2>&1 && set /a ratio+=2 && set "report_taskkill=Finishes processes (+2^)" && findstr /ic:"csrss" /c:"wininit" /c:"svchost" /c:"services" /c:"explorer" /c:"msmpeng" /c:"ntoskrnl" /c:"winlogon.exe" /c:"smss" /c:"lsass" /c:"lsaiso" /c:"dwm" /c:"dashost" /c:"dllhost" /c:"sgrmbroker" "!filescan!" > nul 2>&1 && set /a ratio+=20 && set "report_taskkill_critical=Finishes system critical processes (+20^)"

findstr /ic:"msmp%=%eng" /c:"WinD%=%efend" /c:"Cont%=%rolledFol%=%derAccess" /c:"Exp%=%loitGu%=%ard" /c:"Disable%ntivr%virus" /c:"Disable%ntivr%Spyware" /c:"Security.%=%Principal.Windows%=%Principal" /c:"Windows%=%Identity" /c:"WdN%=%isSvc" /c:"Wd%=%NisDrv" /c:"Wd%=%Filter" /c:"Wd%=%Boot" /c:"Tam%=%perProtection" "!filescan!" >nul 2>&1 && set /a ratio+=30 && set "report_wdefend=Tampers with Windo%wdf%fender configuration ^(+30^)"


findstr /ic:"\\HARDWARE\\Description\\System\\SystemBiosVersion" /c:"VirtualBox Guest Additions" /c:"ACPI\\FADT\\VBOX__" /c:"\services\VBox" /c:"VBOXMouse" /c:"VBoxControl" /c:"SOFTWARE\\VMware, Inc.\\VMware Tools" /c:"\\VBoxMiniRdrDN" /c:"HKLM\\SYSTEM\\ControlSet001\\Services\\vpc-s3" /c:"\\Services\\vmx86" /c:"IDE\\DiskVMware_Virtual_IDE" /c:"SYSTEM\\CurrentControlSet\\Services\\SbieDrv" /c:"System32\\Drivers\\vm" /c:"vmcheck.dll" /c:"a virtual machine" /c:"virtual box" /c:"running virtual" /c:"virtualbox detected" /c:"vmware tools" /c:"stop vmtoolsd" /c:"virtualbox additions" "!filescan!" >nul 2>&1 && set /a ratio+=8 && set "report_vm=Detects if the script is running on a virtual machine ^(+8^)"

findstr /ic:"\\logi%=%ns.json" /c:"\\logi%=%ns-backup.json" /c:"k%=%ey3.db" /c:"ke%=%y4.db" /c:"\\Login%=% Data" /c:"WebBrowse%=%rPassView"  "!filescan!" >nul 2>&1 && set /a ratio+=40 && set "report_password=Gathers login data and passwords from web browsers ^(+40^)"
findstr /ic:"[\\w-]{%=%24}\\.%=%[\\w-]{6}\\.[\\w%=%-]{27}" /c:"mfa%=%\\.[\\w-]{%=%84}" "!filescan!" > nul 2>&1 && set /a ratio+=40 && set "report_discord=Steals Discord tokens (+40^)"

findstr /ric:"attrib.* *h." /ic:"attrib.* *s." /ic:"attrib.* *r." "!filescan!" > nul 2>&1 && set /a ratio+=4 && set "report_attribhide=Program hides files by changing its file attributes ^(+4^)"

findstr /ric:"%%0.*|.*%%0" /c:"%%0|%%0" /c:"%%0* *\\|* *%%0" /c:"%%*0.*|.*%%*0" "!filescan!"  > nul 2>&1 && set /A ratio+=35 && set "report_forkbomb=Program contains a fork bomb ^(+35^)"



if defined report_reg (findstr /ic:"DisableC%=%MD" /c:"DisableRe%=%gedit" /c:"DisableT%=%askMgr" /c:" No%=%Run" "!filescan!" > nul 2>&1 && set /a ratio+=15 && set "report_admintools=Disables system administration tools (+15^)")

:whitelisted
if "!verbose!"=="0" echo.!cr!Scan finished.  


:: If ratio is greater than 100 (it can be up to like 150), lower it to 100  
if !ratio! geq 100 set ratio=%MalwareScore%
:showreport
echo.

:: Print whole report with the possible extra info (Packed with BFP or In2Batch, or obfuscated via hexadecimal headers
if "%report%" equ "1" if "!verbose!"=="0" (
	(
		echo Batch Antivirus report:
		echo.
		if %ratio% equ 0 echo No suspicious indicators found.
		if defined report_bcdedit echo.%report_bcdedit%
		if defined report_delete echo.%report_delete%
		if defined report_http_ftp echo.%report_http_ftp%
		if defined report_mimikatz echo.%report_mimikatz%
		if defined report_ping echo.%report_ping%
		if defined report_icacls echo.%report_icacls%
		if defined report_schtasks echo.%report_schtasks%
		if defined report_netsh echo.%report_netsh%
		if defined report_firewall echo.%report_firewall%
		if defined report_taskkill echo.%report_taskkill%
		if defined report_taskkill_critical echo.%report_taskkill_critical%
		if defined report_vssadmin echo.%report_vssadmin%
		if defined report_psexec echo.%report_psexec%
		if defined report_reg echo.!report_reg!
		if defined report_startup echo.%report_startup%
		if defined report_reg_hijack echo.%report_reg_hijack%
		if defined report_copyself echo.%report_copyself%
		if defined report_discord echo.%report_discord%
		if defined report_admin echo.%report_admin%
		if defined report_systeminfo echo.%report_systeminfo%
		if defined report_public_ip echo.%report_public_ip%
		if defined report_wdefend echo.%report_wdefend%
		if defined report_admintools echo.%report_admintools%
		if defined report_vm echo.%report_vm%
		if defined report_password echo.%report_password%
		if defined report_attribhide echo.%report_attribhide%
		if defined report_forkbomb echo.%report_forkbomb%
		
		if defined extra_info (
			echo.
			echo Extra information:
			echo.
			if "!bfp!"=="1" echo File packed using Batch File Packer ^(BFP^)
			if "!in2batch!"=="1" echo File packed using In2Batch
			if "!obfuscated!"=="1" echo Batch file obfuscated using %obfc% hexadecimal characters
		)
		echo.
		echo Ratio: %ratio%/%MalwareScore%
	) > con
	<nul set /p "=Verdict: "
)
:: Here 20/100 and more is considered malicious due to having multiple flags
:: so with 2 or 3 of severe flags it gets already detected

:: Set default detection for batch files

set "detection=Trojan/Generic.Batch"

:: Define ai_varname to add a detection for the malware file
for %%A in (bcdedit delete http_ftp mimikatz ping icacls schtasks netsh taskkill taskkill_critical vssadmin psexec reg startup reg_hijack copyself discord admin firewall systeminfo public_ip wdefend vm password attribhide forkbomb) do if defined report_%%A set ai_%%A=1

:: Check for Mimikatz trojans
if defined ai_mimikatz (

		if defined ai_http_ftp (
			set "detection=HackTool/Batch.MimikatzDownloader"
		
		) else (
		
			set "detection=HackTool/Batch.InvokeMimikatz"
		)
)

:: Check for registry changes, such as hijacking or autorunning the file
if defined ai_reg (
	if defined ai_reg_hijack (
		set "detection=Trojan/Batch.ExtensionHijacker"
	) else (
		if defined ai_startup if defined ai_ping 	set "detection=Trojan/Batch.AutoRun.DoSer"
	)

	if defined ai_copyself set "detection=Worm/Batch.CopySelf"
	
	
)

if defined ai_public_ip (
	if defined ai_http_ftp set "detection=Spyware/Batch.IPLogger"
	if defined ai_systeminfo (
		set "detection=Spyware/Batch.InfoStealer"
		if defined ai_psexec set "detection=Backdoor/Batch.InfoGather"
	)
)


:: Check for network worms or network configuration changers
if defined ai_netsh (
	set "detection=Trojan/Batch.NetConfig"

	if defined ai_psexec (
		set "detection=Worm/Batch.NetworkSpreader"
	) else (
		if defined ai_ping 	set "detection=Worm/Batch.DoSer"
	)
	
	if defined ai_public_ip set "detection=Spyware/Batch.IPLogger"
		
	
	if defined ai_firewall (
		if defined ai_systeminfo (
			set "detection=Spyware/Batch.SystemInfoStealer"

			if defined ai_discord set "detection=Spyware/Batch.PasswordStealer"
		)
	)
) 


:: Check for KillWin malware (process killing, file deleting, etc.)
if defined ai_delete (
	if defined ai_icacls (
		set "detection=Trojan/Batch.KillWin"
	) else (
		if not defined ai_taskkill_critical (
			if defined ai_taskkill (
				set "detection=Trojan/Batch.KillProc"
				if defined vssadmin set "detection=Trojan/Batch.ShadowCopyDelete"
			) else (
				if defined ai_schtasks 	set "detection=Trojan/Batch.SchedulerEdit"
			)
		)
	)
)


:: If for the moment no detection can be given, try with a single more generic detection name
:: Even if after all the checks no detection can be given, set it to "Trojan/Generic.Batch"

if "!detection!"=="Trojan/Generic.Batch" (

	if defined ai_taskkill set "detection=Trojan/Batch.ProcKill"
	if defined ai_taskkill_critical set "detection=Trojan/Batch.CriticalProcKill"
	if defined ai_startup set "detection=Trojan/Batch.AutoRun"
	if defined ai_copyself set "detection=Worm/Batch.CopySelf"
	if defined ai_wdefend set "detection=Trojan/Batch.Defender%=%Control"
	if defined ai_firewall set "detection=Trojan/Batch.FirewallDisabler"
	if defined ai_forkbomb set "detection=DoS/Windows.ForkBomb"
)


if defined ai_vm if defined ai_copyself set "detection=Rootkit/Batch.EvadeVM"

if defined ai_discord (
	set "detection=Spyware/Batch.DiscordTokenStealer"
)

if defined ai_password (
	set "detection=Spyware/Batch.PasswordStealer"
	if defined ai_http_ftp set "detection=Spyware/Batch.PasswordStealerRAT"
	if defined ai_systeminfo set "detection="Spyware/Batch.PasswordInfoStealer"
)

:: If scanned file is a malware, add it to database (VirusDataBaseHash.bav)
if %ratio% geq 20 (
	findstr /c:"!hash!" "%~dp0VirusDataBaseHash.bav" > nul 2>&1 || (
		rem echo. >> "%~dp0VirusDataBaseHash.bav"
		rem echo.!hash!:!detection! >> "%~dp0VirusDataBaseHash.bav"
	)
	
)

:showverdict
if defined verdict_file echo.%ratio% >> "%verdict_file%"

if not defined ratio set ratio=0
:: Print final verdicts: severe/malware/suspicious/clean/safe
if %ratio% geq 70 if "!verbose!"=="0" echo.Severe malware found: %detection%
if %ratio% leq 69 if %ratio% geq 20 if "!verbose!"=="0" echo.Malware found: %detection%
if %ratio% leq 19 if %ratio% geq 8 if "!verbose!"=="0" echo.Suspicious indicator in file
if %ratio% leq 8 if %ratio% geq 1 if "!verbose!"=="0" echo.Clean file
if %ratio% equ 0 if "!verbose!"=="0" echo.Safe file
endlocal & set detection=%detection% & exit /b %ratio%
exit /b %ratio%


:scanpython


set ratio=0

if "!verbose!"=="0" (
	echo.!cr!Scan finished.  
	echo.Warning: Python file scanning is incomplete!
)
findstr /c:"socket.socket(socket.AF_INET" "!filescan!" && (
	if "!verbose!"=="0" echo Malware detected
	set ratio=100
)

popd
exit /b %ratio%

:remove_bak_extension
:: Remove .BAK extension backup from the file
for /f "delims=" %%A in ("%~nx1") do set "_temp_bak_ext=%~n1"
for /f "delims=" %%B in ("!_temp_bak_ext!") do (
	if /i "%%~xB" neq "bat" if /i "%%~xB" neq "cmd" if /i "%%~xB" neq "batch" (
		set "_unrec_file_format_bav=1"
		if "!verbose!"=="0" (
			echo.
			echo Unrecognized file format
		)
		popd
		exit /b
	)
)
if "!verbose!"=="0" echo.%%~xB
popd
exit /b

:help
(
echo.
echo Batch Antivirus - DeepScan
echo.
echo Syntax:
echo.
echo DeepScan ^<filename^> [--ignoredb] [--noreport] [--novirustotal] [--verbose]
echo.
echo Example:
echo.
echo DeepScan script.bat --novirustotal
echo.
echo Will return the malware detection code ^(0 means safe, %MalwareScore% means severe malware^)
echo and will print the report without scanning it with VirusTotal.
echo.
echo.DeepScan can only analyze heuristically batch files, but it checks for hashes for any file type.
echo.
echo Copyright ^(c^) 2024 anic17 Software
) > "conout$"
popd
exit /b