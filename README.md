

# Batch Antivirus
<a href="https://github.com/anic17/Batch-Antivirus/stargazers">![batch-antivirus-stars](https://img.shields.io/github/stars/anic17/Batch-Antivirus?color=yellow&style=flat-square)</a> <a href="https://github.com/anic17/Batch-Antivirus/network/members">![batch-antivirus-forks](https://img.shields.io/github/forks/anic17/Batch-Antivirus?style=flat-square)</a> ![batch-antivirus-downloads](https://img.shields.io/github/downloads/anic17/Batch-Antivirus/total?color=green&style=flat-square) <a href="https://www.gnu.org/licenses/gpl-3.0">![batch-antivirus-license](https://img.shields.io/github/license/anic17/Batch-Antivirus?style=flat-square)</a> <a href="https://github.com/anic17/Batch-Antivirus/issues">![batch-antivirus-issues](https://img.shields.io/github/issues/anic17/Batch-Antivirus?style=flat-square)</a>

Official repository of Batch Antivirus. Batch Antivirus is a powerful antivirus suite written in batch with real-time protection and heuristical scanning. 
For a more in-depth explanation, go to [Batch Antivirus webpage](https://anic17.github.io/Batch-Antivirus).

## Motives and History

# The Evolution of Batch Antivirus

Batch Antivirus began as a proof-of-concept project in June 2020 with a simple idea: to create a lightweight antivirus powered by a small malware hash database. The program initially calculated file hashes and checked them against this database for potential threats.

Before adopting the name Batch Antivirus (BAV), the project was known as Scripting Windows Host AntiVirus (SWHAV), as it originated as a package for [Scripting Windows Host](https://github.com/anic17/SWH).

Over time, Batch Antivirus grew far beyond its original scope. Advanced features like real-time protection and a heuristic batch scanner were integrated, demonstrating the potential of batch scripting for cybersecurity and for antimalware solutions.

As of December 2024, Batch Antivirus has evolved into a robust antimalware suite. It now includes seven powerful modules and three additional utilities including an auto-updater, significantly enhancing its protection capabilities which makes Batch Antivirus stand out from a very long distance from other batch antimalware attempts.

# Features of Batch Antivirus

 - World's most precise automated batch file behavior analyzer
   - Profoundly scans batch files
   - Includes 25 unique behavior detection patterns
   - Detects whether obfuscation techniques are used
   - Bypasses and flags commonly used anti-antivirus techniques
   - Provides an accurate naming of new detections
   - Returns a malicious behavior score on a scale over 100
   - Online VirusTotal analysis
- Real-time protection
   - Real-time file protection
   - Real-time web protection
   - Real-time process analyzer
   - Kill protection with double watchdog process
   - Background real-time protection
   - PC Monitor, which checks for free disk space & CPU overheating
 - Website blocker (requires real-time protection to be running)
 - Full disk scanner
   - Scans for essential computer registry keys for malware
 - USB malware scanner & remover
   - Scans and deletes shortcut malware
   - Identifies and removes `autorun.inf` malware
 - Auto updater (both antivirus and databases)
 - Curated hash and IP database for the newest detections
   - 185k SHA256 hash database with accurate detection names
   - 373k IP database
 - Autorun configuration of the antivirus
    - Boot-time real-time protection that initiates before any other startup program (even `explorer.exe`)
 - Safe and isolated quarantine
   - Includes a quarantine viewer with information about the quarantined files
   - Files are base-64 encoded and ACL-locked, preventing even administrator-level processes from interacting with them
 - An experimental file association interception (use it at your own risk!)

# Frequently Asked Questions

## Is Batch Antivirus suitable for use as a primary antivirus solution?

Regrettably, the answer is no. Batch Antivirus relies on a relatively small database (185k hashes). Despite its apparent size, the continuous emergence of new malware poses a significant challenge in maintaining up-to-date definitions. The more severe malware detections are kept up to date.
Batch Antivirus provides effective file monitoring and common malware detection capabilities, however, the combined use of Batch Antivirus and an alternative antivirus solution is strongly recommended. Think of Batch Antivirus as an extra protection layer.

## Does Batch Antivirus need to be installed?

No, Batch Antivirus can be used portably. Real-time protection relies on folder change monitoring and not on kernel drivers. Although not needed, running real-time protection (`RealTimeProtection.bat`) and the drive scanner (`BAV.bat`) with administrator privileges to scan system files is recommended.  
If you're willing to have better security, consider adding Batch Antivirus as an autorun with [`BAVAutorun.bat`](https://github.com/anic17/Batch-Antivirus/blob/master/BAVAutorun.bat) and selection option 3 (shell). Setting Batch Antivirus as your shell will run the protection before any other startup program.

## Why is scanning so slow?

The speed of drive scanning is constrained by the inherent limitations of batch processing, particularly in launching new processes. Nonetheless, significant optimizations have been implemented to speed up folder scanning during real-time protection.

## Does web protection register websites I visit?

No, Batch Antivirus doesn't collect any data because user's privacy is a priority. To get the active TCP connections, Batch Antivirus uses the command `netstat -no` to retrieve the data. Afterwards, the IPs found are looked up on `VirusDataBaseIP.bav` database to check if a malicious or blocked website was visited.

## Does the website blocker modify my computer's hosts file?

Thanks to the real-time protection module, the website blocker operates without modifying any system files, including the `hosts` file. Instead, it employs the same approach as the web protection feature to restrict access to blocked sites.

## I found malicious files, where can I send you its SHA256 hash?

Contribute by creating a [pull request](https://github.com/anic17/Batch-Antivirus/pulls). Alternatively, you can send malicious hashes at batch.antivirus@gmail.com or [contact me](#contact)

## Why does the heuristical analyzer sometimes detects legitimate programs?

The Deep scanner module checks for patterns usually found in malware. Even though it has been adjusted to minimize false positives, it is impossible to mitigate all false positives. Programs that change registry settings or tweaker scripts are susceptible to false positives due to their potentially dangerous behavior and similarity to malicious scripts.

## What do I need to do to use a part of the antivirus?

You are allowed to distribute programs that use Batch Antivirus; however, please ensure proper attribution by crediting me and providing a link to this repository and any other component used (such as the databases). Your support in promoting this project is greatly valued and contributes to its visibility. Thank you for your cooperation.

## Contact

Feel free to contact me on Discord (@anic17) or my server <a href="https://discord.gg/gfmaxgE">Program Dream</a>.  
<a href="https://discord.gg/gfmaxgE"><img src="https://img.shields.io/discord/728958932210679869?style=flat-square&logo=appveyor"></a>


**Copyright &copy; 2024 anic17 Software**
<!-- 
View counter 
-->
<img src="https://hits.seeyoufarm.com/api/count/incr/badge.svg?url=https%3A%2F%2Fgithub.com%2Fanic17%2FBatch-Antivirus&count_bg=%23FFFFFF&title_bg=%23FFFFFF&icon=&icon_color=%23FFFFFF&title=hits&edge_flat=false" height=0 width=0>
