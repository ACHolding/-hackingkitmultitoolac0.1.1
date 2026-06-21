@echo off
setlocal enabledelayedexpansion
title AC's Hacking Kit 0.1
color 0A
mode con cols=120 lines=55

:: ============================================================
:: ROOT DIRS
:: ============================================================
set "ROOT=%~dp0AC_Hacking_Kit_0.1"
if not exist "%ROOT%" mkdir "%ROOT%"
set "LOGS=%ROOT%\logs"
if not exist "%LOGS%" mkdir "%LOGS%"
set "WORDLISTS=%ROOT%\wordlists"
if not exist "%WORDLISTS%" mkdir "%WORDLISTS%"
set "OUTPUTS=%ROOT%\outputs"
if not exist "%OUTPUTS%" mkdir "%OUTPUTS%"

:: ============================================================
:: TIMESTAMP
:: ============================================================
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value 2^>nul') do set "dt=%%I"
set "FULL_STAMP=%dt:~0,4%-%dt:~4,2%-%dt:~6,2%_%dt:~8,2%%dt:~10,2%%dt:~12,2%"
set "LOG_FILE=%LOGS%\ac_hack_%FULL_STAMP%.log"
echo [AC's Hacking Kit 0.1] START %DATE% %TIME% > "%LOG_FILE%"

:: ANSI
for /f %%A in ('"prompt $E$S & for %%B in (1) do rem"') do set "ESC=%%A"
set "RED=%ESC%[91m"
set "GREEN=%ESC%[92m"
set "YELLOW=%ESC%[93m"
set "CYAN=%ESC%[96m"
set "RESET=%ESC%[0m"

:: Wordlists
if not exist "%WORDLISTS%\subdomains.txt" (
    echo www mail ftp admin dev test api vpn secure internal > "%WORDLISTS%\subdomains.txt"
)

:mission_brief
cls
echo %CYAN%===============================================================================%RESET%
echo %CYAN%                    AC's Hacking Kit 0.1%RESET%
echo %CYAN%===============================================================================%RESET%
echo.
echo %YELLOW%[+] Session: %FULL_STAMP%%RESET%
echo.

:main_menu
cls
echo %CYAN%[ MAIN MENU ]%RESET%
echo.
echo %GREEN%[1]%RESET% Ping Sweeper
echo %GREEN%[2]%RESET% Port Scanner
echo %GREEN%[3]%RESET% Subdomain Brute
echo %GREEN%[4]%RESET% Web Path Fuzzer
echo %GREEN%[5]%RESET% Header Grabber
echo %GREEN%[6]%RESET% ARP Scanner
echo %GREEN%[7]%RESET% Traceroute
echo %GREEN%[8]%RESET% System Profiler
echo %GREEN%[9]%RESET% Mini Web Server
echo %GREEN%[D]%RESET% Port Knocking
echo %GREEN%[E]%RESET% View Logs
echo %GREEN%[X]%RESET% Exit
echo.
set /p "choice=Select: "

if "%choice%"=="1" goto ping_sweep
if "%choice%"=="2" goto port_scan
if "%choice%"=="3" goto subdomain_brute
if "%choice%"=="4" goto web_fuzz
if "%choice%"=="5" goto header_grab
if "%choice%"=="6" goto arp_scan
if "%choice%"=="7" goto traceroute
if "%choice%"=="8" goto sys_profiler
if "%choice%"=="9" goto mini_webserver
if /i "%choice%"=="D" goto port_knock
if /i "%choice%"=="E" goto view_logs
if /i "%choice%"=="X" goto exit_script
goto main_menu

:ping_sweep
set /p "network=Target network: "
for /l %%i in (1,1,254) do ping -n 1 -w 200 !network!.%%i | find "Reply" >> "%OUTPUTS%\ping_%FULL_STAMP%.txt" 2>nul
echo Done.
pause
goto main_menu

:port_scan
set /p "target=Target IP: "
powershell -nop -c "$ports = '21,22,80,443,445,8080,3389'; $ports -split ',' | %% { try { $tcp=New-Object System.Net.Sockets.TcpClient; $tcp.Connect($target, $_); Write-Host 'OPEN:' $_; $tcp.Close() } catch {} }" 2>nul
pause
goto main_menu

:subdomain_brute
set /p "domain=Domain: "
for /f %%w in (%WORDLISTS%\subdomains.txt) do ping -n 1 %%w.!domain! >nul 2>&1 && echo [FOUND] %%w.!domain!
pause
goto main_menu

:web_fuzz
set /p "url=Base URL: "
for %%p in (admin login dashboard phpmyadmin .env config backup) do powershell -nop -c "try { Invoke-WebRequest -Uri '%url%%%p' -TimeoutSec 3 -UseBasicParsing | Select StatusCode } catch {}" 2>nul
pause
goto main_menu

:header_grab
set /p "url=URL: "
powershell -nop -c "Invoke-WebRequest -Uri '%url%' -UseBasicParsing | Select Headers | Format-List" 2>nul
pause
goto main_menu

:arp_scan
arp -a
pause
goto main_menu

:traceroute
set /p "target=Target: "
tracert %target%
pause
goto main_menu

:sys_profiler
systeminfo
pause
goto main_menu

:mini_webserver
echo Starting mini server on port 8080...
powershell -nop -c "$l=New-Object System.Net.HttpListener; $l.Prefixes.Add('http://*:8080/'); $l.Start(); Write-Host 'Server running - Ctrl+C to stop'; while($true){$c=$l.GetContext(); $r=$c.Response; $b=[Text.Encoding]::UTF8.GetBytes('<h1>AC Hacking Kit 0.1</h1>'); $r.OutputStream.Write($b,0,$b.Length); $r.Close()}" 
pause
goto main_menu

:port_knock
set /p "target=Target: "
set /p "seq=Port sequence: "
for %%p in (%seq%) do powershell -nop -c "$t=New-Object System.Net.Sockets.TcpClient; try { $t.Connect('%target%',%%p); Write-Host '[KNOCK]' %%p; $t.Close() } catch {}" 2>nul
pause
goto main_menu

:view_logs
type "%LOG_FILE%"
pause
goto main_menu

:exit_script
echo AC's Hacking Kit 0.1 terminated.
pause
exit