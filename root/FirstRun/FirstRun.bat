@echo off
setlocal EnableDelayedExpansion
set path=%path%;%~dp0
if not "%ProgramFiles(x86)%"=="" (
set u=%~dp0x64
) else set u=%~dp0x86
echo sorting updates..
for /f "tokens=*" %%i in ('^
dir /b "%u%" ^|
sed "s/^.*KB\|^.*kb//g;s/).*$//g" ^|
sed "s/[ \t]*$//" ^|
gnusort -n ^|
sed "/^$/d"') do (
for /f "tokens=*" %%d in ('dir /b "%u%" ^| grep "%%i"') do (
echo installing KB%%i
for /f "tokens=*" %%z in ('dir /b "%u%\%%d\*.msu" "%u%\%%d\*.exe"') do (
echo %%z | grep "\.exe" > nul 2>&1
if !errorlevel!==0 start /wait "" "%u%\%%d\%%z" /passive /norestart
if not !errorlevel!==0 echo %%z returns !errorlevel!
echo %%z | grep "\.msu" > nul 2>&1
if !errorlevel!==0 %systemroot%\system32\wusa.exe "%u%\%%d\%%z" /quiet /norestart
if not !errorlevel!==0 echo %%z returns !errorlevel!
)
)
)
endlocal

net stop wuauserv
rd %systemroot%\SoftwareDistribution /Q /S
SC sdshow wuauserv
SC sdset wuauserv D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;AU)(A;;CCLCSWRPWPDTLOCRRC;;;PU)
wuauclt.exe /detectnow

%systemroot%\system32\shutdown.exe -r -t 0 -f
