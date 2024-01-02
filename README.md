

# Batch Antivirus
<a href="https://github.com/anic17/Batch-Antivirus/stargazers">![batch-antivirus-stars](https://img.shields.io/github/stars/anic17/Batch-Antivirus?color=yellow&style=flat-square)</a> <a href="https://github.com/anic17/Batch-Antivirus/network/members">![batch-antivirus-forks](https://img.shields.io/github/forks/anic17/Batch-Antivirus?style=flat-square)</a> ![batch-antivirus-downloads](https://img.shields.io/github/downloads/anic17/Batch-Antivirus/total?color=green&style=flat-square) <a href="https://www.gnu.org/licenses/gpl-3.0">![batch-antivirus-license](https://img.shields.io/github/license/anic17/Batch-Antivirus?style=flat-square)</a> <a href="https://github.com/anic17/Batch-Antivirus/issues">![batch-antivirus-issues](https://img.shields.io/github/issues/anic17/Batch-Antivirus?style=flat-square)</a>

Official repository of Batch Antivirus. Batch Antivirus is a powerful antivirus suite written in batch with real-time protection and heuristical scanning. 
For a more in-depth explanation, go to [Batch Antivirus webpage](https://anic17.github.io/Batch-Antivirus).

# Features of Batch Antivirus

 - Drive scanner
 - Auto-updater (both antivirus and databases)
 - Deep Scanning (for batch files)
 - 192k SHA256 hash database
 - 313k IP database
 - USB Scanner for malware
 - USB shortcut malware remover
 - Autorun configuration of the antivirus
 - Real-time file protection
 - Real-time web protection
 - PC Monitor, which checks for disk space & CPU temperature
 - Kill protection for real-time protection
 - Background real-time, starting before any other startup program (even `explorer.exe`)
 - Quarantine (files are encoded in base64 and locked)
 - Quarantine viewer
 - File opening interception
 - VirusTotal analysis (On DeepScan)

# Frequent Asked Questions

## Is Batch Antivirus good enough to use as a regular antivirus?

Sadly, the answer is no. Batch Antivirus contains a small database (192k hashes). Although it may seem like it's a lot, the fact that new malware is appearing makes it very difficult to be up-to-date with the latest definitions.
Batch Antivirus can do a great job monitoring files, but if you want a safe system you need to use another antivirus solution. Think of Batch Antivirus as an extra protection layer.

## Does Batch Antivirus need to be installed?

No, Batch Antivirus can be used portably. Real-time protection relies on folder changing and not on kernel drivers. Although it's not needed, it is recommended to run real-time protection (`RealTimeProtection.bat`) and the drive scanner (`BAV.bat`) with administrator privileges to scan system files.  

If you're willing to have better security, consider adding Batch Antivirus as an autorun with [`BAVAutorun.bat`](https://github.com/anic17/Batch-Antivirus/blob/master/BAVAutorun.bat) and selection option 3 (shell). Setting Batch Antivirus as your shell will run the protection before any other startup program.

## Why is scanning so slow?

Drive scanning is slow because of the slow nature of batch of launching new processes. Nonetheless, it has been optimized when scanning folders in real-time protection.

## Does web protection register websites I visit?

No, Batch Antivirus doesn't collect **any** data.  
Privacy is always important. Batch Antivirus uses the command `netstat -no` to get the active TCP connections to the PC. Then they're searched on `VirusDataBaseHash.bav` database to check if it's a malicious website. Nothing else.

## I accidentally found some malware, where can I send you the SHA256 hash?

Contribute by creating a [pull request](https://github.com/anic17/Batch-Antivirus/pulls). Alternatively, you can send malicious hashes at batch.antivirus@gmail.com or [contact me](#contact)


## Why does the heuristical analyzer detect legitimate programs?

The Deep scanner module checks for patterns usually found in malware. Even though it has been adjusted to minimize false positives, some programs may give false positives as their behavior may be similar to malicious programs.

## What do I need to do if I want to use a part of the antivirus?

You can distribute programs that use Batch Antivirus, but please credit me and link this repository. It helps give more visibility to this project and it is highly appreciated.

## Contact

Feel free to contact me on Discord (ID 684471165884039243)  
<a href="https://discord.gg/J628dBqQgb"><img src="https://img.shields.io/discord/728958932210679869?style=flat-square&logo=appveyor"></a>


**Copyright &copy; 2024 anic17 Software**
<!-- 
View counter 
-->
<img src="https://hits.seeyoufarm.com/api/count/incr/badge.svg?url=https%3A%2F%2Fgithub.com%2Fanic17%2FBatch-Antivirus&count_bg=%23FFFFFF&title_bg=%23FFFFFF&icon=&icon_color=%23FFFFFF&title=hits&edge_flat=false" height=0 width=0>
