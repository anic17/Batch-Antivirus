::BAV_:git@github.com:anic17/Batch-Antivirus.git
@echo off
setlocal EnableDelayedExpansion
title Batch Antivirus threat detail
echo.Batch Antivirus threat detail
echo.
set /p "threat_name=Threat name: "

findstr /ic:"!threat_name!" "%~dp0VirusDataBaseHash.bav "> nul 2>&1 || echo Threat not found in the database

for /f "tokens=1 delims=/" %%A in ("!threat_name!") do set "mal_type=%%A"
set found_malware=0
for %%A in (
"Adware`A malware that shows ads which is frequently installed by PUP (Potentially Unwanted Programs)"
"BackDoor`This malware allows remote access to the computer by an attacker"
"Banker`This malware steals banking information with the purpose of stealing money"
"Constructor`This program is used to build other malware"
"DDoS`A distributed DoS attack ^(DDoS^), which has the purpose of flooding a service in order to disable it"
"DiscordTokenLogger`A very concrete variant of spyware: Its only purpose are Discord logins"
"DoS`This malware has the purpose of flooding a service in order to disable it"
"Eicar-TestFile`Not a malware. A file used for antivirus testing"
"Email-Worm`This malware replicates itself by sending emails or messages which contain the malware"
"Exploit`A critical vulnerability exploited by a malware"
"Flooder`This malware floods a service"
"FormBook`Similar to a Spyware, this program steals information from the user"
"HackTool`This program is a tool that can be used by hackers for malicious purposes"
"Joke`This program is harmless but annoys the user making him think he got infected by a real malware"
"Keylogger`This malware logs all the keys pressed by the user, usually targetted for getting passwords"
"Miner`This malware uses your PC resources to mine cryptocurrencies."
"PUA`This program gets installed with bundled setups and annoys the user by asking the user for a paid version or doing unwanted actions"
"PUP`This program gets installed with bundled setups and annoys the user by asking the user for a paid version or doing unwanted actions."
"PasswordStealer`A variant of spyware, whose only purpose is to steal passwords and logins"
"RAT`This`program allows remote access to the computer which is installed by another person"
"Ransom`This malware encrypts/locks all your files and asks for a ransom in order to decrypt/unlock them"
"Rootkit`A very dangerous type of malware which is frequently installed in the UEFI to monitor the system from a very low level"
"Spyware`This malware steals information from the user such as passwords and banking information"
"Trojan-Downloader`This malware downloads and runs another malware, which is usually more dangerous than the downloader"
"Trojan-PSW`A variant of spyware, whose only purpose is to steal passwords and logins"
"TrojanDropper`This malware drops and runs another malware, usually more dangerous which can perform any type of action"
"Trojan`This malware runs malicious code from an attacker on the targetted computer"
"VirTool`The same as a Constructor, which is used to build other malwares"
"Virus`This malware replicates itself into the system and infects other files"
"Worm`This malware replicates itself into the infected network"

) do for /f "tokens=1* delims=`" %%X in ("%%~A") do if /i "%%~X"=="!mal_type!" (echo.%%~X: %%~Y&&set "found_malware=1")
if "!found_malware!"=="0" (
	echo.Could not find the detection "!mal_type!" in database
)
echo.
echo.Press any key to quit...
pause>nul
exit /b