# Batch Antivirus

In this repository you will find the best Batch-created Antivirus: Batch Antivirus! (BAV)
We store the database and antivirus components. Please ensure to download all files for a better protection.

## Is Batch Antivirus good enough to use as a regular antivirus?

Sadly, answer is no. Batch Antivirus contains a small database (40000 hashes), so new malware isn't there. 
We recomend using another antivirus such as Microsoft Defender or Malwarebytes.  
But, if you can use real-time protection along Microsoft Defender, that will be safer.


## Does Batch Antivirus needs to be installed?

No, you can use it portably with a non-administrator account. It doesn't create any services nor processes.


## Why is scanning so slow?

Scanning is slow because it launches a different process for every file. We're trying to optimize it. There's no new version for `BAV.bat` because of that.

## Does web protection register websites I visit?

No, Batch Antivirus doesn't collect **any** data.  
Privacy is always important for us. Batch Antivirus uses the command `netstat -no` to get active connections to the PC. Then it compares to the file `VirusDataBaseIP.bav` and if the IP is found, it's a malicious website.  
So no, we don't collect any data.


## Hey! I accidentally downloaded some malware, where can I send SHA256 hash?

Send malicious hashes at batch.antivirus@gmail.com


## Why does heuristical analyzer detect legitimate programs?

It checks for API/system calls and behaviour. It might be a false positive as it uses some suspicious API like CryptoAPI, used sometimes in ransomware.


## What I need to do if I want to use the database?

You can distribute and sell programs along with database, but please credit us as it's not easy to make a such database searching a big part of the hashes manually.



**Copyright (c) 2020 anic17 Software.**
