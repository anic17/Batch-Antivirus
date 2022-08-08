

# Batch Antivirus
<a href="https://github.com/anic17/Batch-Antivirus/stargazers">![batch-antivirus-stars](https://img.shields.io/github/stars/anic17/Batch-Antivirus?color=yellow&style=flat-square)</a> <a href="https://github.com/anic17/Batch-Antivirus/network/members">![batch-antivirus-forks](https://img.shields.io/github/forks/anic17/Batch-Antivirus?style=flat-square)</a> <a href="https://www.gnu.org/licenses/gpl-3.0">![batch-antivirus-license](https://img.shields.io/github/license/anic17/Batch-Antivirus?style=flat-square)</a> <a href="https://github.com/anic17/Batch-Antivirus/issues">![batch-antivirus-issues](https://img.shields.io/github/issues/anic17/Batch-Antivirus?style=flat-square)</a>

In this repository you will find the best Batch-created Antivirus: Batch Antivirus! (BAV)
The database and antivirus components are all here. Please ensure to download all files for a better protection.

## Is Batch Antivirus good enough to use as a regular antivirus?

Sadly, the answer is no. Batch Antivirus contains a small database (40k hashes), so new malware isn't there. 
We recomend using another antivirus such as Microsoft Defender or Malwarebytes.  
But, if you can use real-time protection along Microsoft Defender, that will be safer.

You can always contribute to make it better. 

## Does Batch Antivirus needs to be installed?

No, you can use it portably with a non-administrator account. It doesn't create any services nor processes. Real time protection relies on folder changing and not on kernel drivers.

## Why is scanning so slow?

Scanning is slow because it launches a different process for every file. We're trying to optimize it. There's no new version for `BAV.bat` because of that.

## Does web protection register websites I visit?

No, Batch Antivirus doesn't collect **any** data.  
Privacy is always important. Batch Antivirus uses the command `netstat -no` to get active connections to the PC. Then it compares to the file `VirusDataBaseIP.bav` and if the IP is found, it's a malicious website. Nothing else.

## I accidentally found some malware, where can I send SHA256 hash?

Send malicious hashes at batch.antivirus@gmail.com or [contact me](#contact)


## Why does heuristical analyzer detect legitimate programs?

It checks for API/system calls and behaviour. It might be a false positive as it uses some suspicious API like CryptoAPI, used sometimes in ransomware.


## What I need to do if I want to use a part of the antivirus?

You can distribute programs that use Batch Antivirus, but please credit me as it's not easy to make a such database searching a big part of the hashes manually and making a real batch antivirus.

## Contact

Feel free to contact me on Discord (ID 684471165884039243)  
<a href="https://discord.gg/J628dBqQgb"><img src="https://img.shields.io/discord/728958932210679869?style=flat-square&logo=appveyor"></a>


**Copyright &copy; 2022 anic17 Software**
<!-- 
View counter 
-->
<img src="https://hits.seeyoufarm.com/api/count/incr/badge.svg?url=https%3A%2F%2Fgithub.com%2Fanic17%2FBatch-Antivirus&count_bg=%23FFFFFF&title_bg=%23FFFFFF&icon=&icon_color=%23FFFFFF&title=hits&edge_flat=false" height=0 width=0>
