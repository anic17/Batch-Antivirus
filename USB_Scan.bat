::BAV_:git@github.com:anic17/Batch-Antivirus.git
@echo off
for %%a in (
	A
	B
	C
	D
	E
	F
	G
	H
	I
	J
	K
	L
	M
	N
	O
	P
	Q
	R
	S
	T
	U
	V
	W
	X
	Y
	Z
) do (
	set disk=%%a
	if exist %%a:\ call :scan %%a
)
echo Finished
pause>nul
goto :EOF

:scan
set "scan=%~1:\"
attrib -h -s autorun.inf 2>nul 1>nul
if exist %scan%autorun.inf call :autorun_found %scan%
goto :EOF

:autorun_found
findstr /c:"Open" %1autorun.inf 2>nul 1>nul
if errorlevel 1 goto :EOF


for /f "tokens=2* delims==" %%A in (%~1\autorun.inf) do (call :analyze %%A)
goto :EOF

:analyze
if not exist "%disk%:\%~1" (if not exist "%~1" goto :EOF)
for /f %%H in ('certutil -hashfile "%~1" SHA256 ^| findstr /vc:"h"') do (set "hash=%%H")

findstr /c:"%hash%" "VirusDataBaseHash.swhav" 2>nul 1>nul
if errorlevel 1 goto :EOF
for /f "tokens=2* delims=:" %%A in ('findstr /c:"%hash%" "VirusDataBaseHash.swhav"') set "detection=%%B"
echo Malware detected ^| %detection%
goto :EOF




certutil -hashfile %autorunfile% SHA256 | findstr /v /c:"SHA256" /c "CertUtil" "VirusDataBaseHash.swhav"
if errorlevel 0 goto :EOF
certutil -hashfile %autorunfile% SHA256 | findstr /v /c:"SHA256" /c "CertUtil" > "%TMP%\hash.256"
for /f "usebackq delims=" %%H in ("%TMP%\hash.256") do (set hashfile=%%H)
for /f "tokens=2 delims=;" %%u in (findstr /c:"%hashfile%" "VirusDataBaseHash.swhav") do (echo Malware found: %%u)
goto :EOF
 


