::BAV_:git@github.com:anic17/Batch-Antivirus.git
@echo off
setlocal EnableDelayedExpansion
title Batch Antivirus Threat Detail
echo.Batch Antivirus Threat Detail
echo.
set "threat_name=%~1"

if "%~1"=="" set /p "threat_name=Threat name: "
set "threat_name=!threat_name:"=!"
if "!threat_name:~1,2!"==":\" set aspath=1
if exist "!threat_name!" if "!threat_name:/=!_"=="!threat_name!_" set aspath=1


if "!aspath!"=="1" (
	if "%~1"=="" (
		echo.[Interpreting input as a file instead of a detection name]
	) else (
		echo.[Interpreting command-line arguments as a file instead of a detection name]
	)
	set detection=
	call "%~dp0DeepScan.bat" "!threat_name!" --verbose
	
	if defined detection 	(
		set "threat_name=!detection!"
		echo.Malware found: !threat_name!
	) else (
		echo No threats found in '%~1', no detection could be given
		goto quit
	)
) else (
	findstr /ic:"!threat_name!" "%~dp0VirusDataBaseHash.bav "> nul 2>&1 || (
		echo Threat not found in the database
		goto quit
	)
)
for /f "tokens=1,2 delims=/" %%A in ("!threat_name!") do (
	set "mal_type=%%A"
	for /f "tokens=1 delims=." %%X in ("%%B") do set "mal_system=%%~X"
)

set found_malware=0
for %%A in (
	"Adware`Malware that displays unwanted ads, often installed by Potentially Unwanted Programs (PUP)."
	"Backdoor`A type of malware that enables unauthorized remote access to a device, bypassing normal authentication."
	"Botnet`A network of infected devices controlled remotely to perform coordinated malicious activities."
	"Constructor`A program used to create other malware, enabling attackers to design customized threats."
	"DiscordTokenStealer`A spyware variant that specifically targets Discord login tokens to compromise accounts."
	"DoS`Malware designed to overwhelm a service or system, making it inaccessible to legitimate users."
	"EICAR-TestFile`A harmless file created to test antivirus software functionality and responses."
	"Email-Flooder`Malware that floods email inboxes with large volumes of messages, causing disruption."
	"Email-Worm`A self-replicating malware that spreads via email attachments or links."
	"Exploit`Malware that leverages vulnerabilities in software or systems to gain unauthorized access or control."
	"Flooder`Malware that sends excessive data to a target, overwhelming and disrupting its functionality."
	"Forkbomb`A denial-of-service attack where processes continuously replicate, consuming all system resources."
	"FormBook`Malware that logs user activity and steals credentials, often used to collect sensitive information."
	"Gen`A generic detection name for malware identified by behavioral or heuristic analysis, not specific signatures."
	"HackTool`Software used by attackers for hacking, including password recovery tools or exploit builders."
	"Hoax`A misleading program that tricks users into believing their system is infected or at risk."
	"HoneyPot`A decoy system or file set up to detect or analyze malware behavior and attacker methods."
	"IM-Flooder`Malware that floods instant messaging services with excessive messages, disrupting communication."
	"IM-Worm`Malware that spreads through instant messaging platforms by sending malicious links or files."
	"IRC-Worm`A worm designed to spread via IRC (Internet Relay Chat) networks by sending malicious messages."
	"Joke`A harmless but annoying program designed to trick users into believing they are infected."
	"Keylogger`Malware that records keystrokes to capture sensitive information, such as passwords and PINs."
	"Macro`Malware that exploits macros in software like Microsoft Office to execute malicious code."
	"Malware`A general term for any software intentionally designed to cause harm or exploit systems."
	"Nuker`A program designed to crash or destabilize a system, often by exploiting vulnerabilities."
	"P2P-Worm`Malware that spreads through peer-to-peer file-sharing networks by disguising itself as legitimate files."
	"PUA`Software that performs unwanted actions, often bundled with free programs."
	"PUP`Software that installs alongside legitimate programs, often displaying ads or altering system behavior."
	"PasswordStealer`A spyware variant designed specifically to steal stored passwords and login credentials."
	"PowerShell`Malware that exploits PowerShell scripting capabilities to execute malicious tasks on Windows systems."
	"RAT (Remote Access Trojan)`Malware that allows an attacker to remotely control the infected system."
	"Ransom`A type of malware that encrypts or locks files, demanding payment for their release."
	"Riskware`Legitimate software that can be exploited by attackers to perform malicious activities."
	"Rogue`Fake antivirus software designed to scare users into paying for unnecessary or fake protection."
	"SMS-Flooder`Malware that sends mass SMS messages, potentially incurring high charges or disrupting communication."
	"Script`Malware written in scripting languages like JavaScript or VBScript to execute malicious code."
	"Shortcut`Malware that creates malicious shortcuts, often redirecting to harmful scripts or programs."
	"Sniffer`Malware that intercepts and logs network traffic to capture sensitive data like passwords or credit card numbers."
	"Spoofer`Malware that disguises its identity or origins to trick users or systems into granting access."
	"Spyware`Malware that secretly collects user information, such as browsing habits, passwords, or financial data."
	"Trojan`Malware that appears legitimate but executes malicious code, often opening backdoors or stealing data."
	"Trojan-AOL`A Trojan targeting AOL users, often stealing credentials or causing disruptions specific to AOL services."
	"Trojan-Clicker`Malware that automates clicking activities, often used to generate fraudulent ad revenue."
	"Trojan-DiskWriter`Malware that writes harmful data to the disk, potentially corrupting files or the file system."
	"Trojan-Diskwritter`Another variant of Trojan-DiskWriter, often used interchangeably."
	"Trojan-Notifier`Malware that sends notifications or data to attackers, often revealing system vulnerabilities."
	"Trojan-PSW`A Trojan designed to steal personal information, particularly passwords and security credentials."
	"Trojan-Proxy`Malware that turns the infected device into a proxy server, often for illegal activities."
	"Trojan-RAT`A Trojan that installs remote access tools, allowing attackers full control of the infected system."
	"Trojan-Spy`Malware that focuses on stealing sensitive information, such as login credentials and browsing data."
	"TrojanDownloader`Malware that downloads and executes additional malicious programs."
	"TrojanDropper`A Trojan that delivers and installs other malware onto the infected system."
	"VirTool`Software used to create or obfuscate malware, aiding in its distribution and evasion."
	"Virus`Malware that infects and replicates itself across files or systems, often damaging or altering them."
	"Win32`A generic detection name for malware targeting the Windows operating system."
	"Worm`Self-replicating malware that spreads across networks, often exploiting vulnerabilities to propagate."
	"Rootkit`Malicious software providing stealthy, unauthorized control over a system, often embedded in kernels or firmware to evade detection."
) do for /f "tokens=1* delims=`" %%X in ("%%~A") do if /i "%%~X"=="!mal_type!" (echo.%%~X: %%~Y&&set "found_malware=1")
if "!found_malware!"=="0" (
	echo.Could not find the detection "!mal_type!" in database
) else (
	for %%# in (
		"Win32/Win64/Win16/Win9x`Malware targeting Windows systems, designed for 32-bit, 64-bit, or legacy architectures."
		"Linux/UNIX/FreeBSD/Solaris`Malware aimed at Linux or Unix-like systems, exploiting platform-specific vulnerabilities."
		"MacOS`Malware crafted for macOS, often targeting dependencies unique to Apple devices."
		"Android/AndroRAT`Malware designed for Android devices, such as remote access tools or spyware."
		"DOS/Boot-DOS/DOS32`Malware targeting DOS environments, often as boot sector viruses."
		"Batch/CMD/Bat`Malware written using Batch scripting that executes malicious commands in the system."
		"QNX`Malware developed for QNX, a real-time operating system commonly used in embedded environments."
		"BeOS`Malware infecting the legacy BeOS operating system."
		"Java/JavaScript`Cross-platform malware leveraging Java or JavaScript for exploits or delivery."
		"VB/VBS`Malware utilizing Visual Basic or VBScript, commonly found in macros and Windows environments."
		"Python`Malware written in Python, often converted into executables for diverse system attacks."
		"Perl/Ruby/Pascal`Niche malware using Perl, Ruby, or Pascal for platform-specific attacks."
		"AutoIt`Malware leveraging AutoIt scripting, frequently used in RAT development."
		"BAS`Malware written in BASIC, often associated with legacy or academic use."
		"MSIL`Malware compiled for Microsoft Intermediate Language, targeting .NET applications."
		"APK`Malicious Android application files containing spyware, RATs, or other malware."
		"PDF`Malware embedded in PDF files, exploiting reader vulnerabilities to execute malicious code."
		"ISO/IMG/CAB/RAR/ZIP`Archive-based malware delivery mechanisms hiding executables or scripts."
		"MSOffice/Excel/MSWord/PowerPoint/Access`Macro-based malware embedded in Microsoft Office documents."
		"SWF/Flash`Malware exploiting vulnerabilities in Flash or SWF files."
		"WinLNK/WinHLP/WinINF`Exploits in Windows shortcut, help, or configuration files."
		"HTML`Malware embedded in HTML files, often used in phishing or drive-by download attacks."
	) do (
		for /f "tokens=1* delims=`" %%X in ("%%~#") do (
			for /f "tokens=1,2,3,4,5 delims=/" %%A in ("%%X") do (
				if /i "%%~A"=="!mal_system!" echo.%%~A: %%Y
				if /i "%%~B"=="!mal_system!" echo.%%~B: %%Y
				if /i "%%~C"=="!mal_system!" echo.%%~C: %%Y
				if /i "%%~D"=="!mal_system!" echo.%%~D: %%Y
				if /i "%%~E"=="!mal_system!" echo.%%~E: %%Y
			)
		)
	)		
)
<nul set /p "=!threat_name!" | findstr /bic:"Ransom/Win32.Acepy" > nul 2>&1 && (
	echo.
	echo.If you have been infected by !threat_name!, there is a decryptor available at:
	set "dcrypt_url=https://github.com/anic17/acepy-decryptor/releases/tag/v1.0"
	echo.!dcrypt_url!
	echo.
	echo.Press any key to open...
	pause>nul
	start "" "!dcrypt_url!"
)
:quit
echo.
echo.Press any key to quit...
pause>nul
exit /b