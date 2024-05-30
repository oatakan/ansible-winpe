@echo on

setlocal enabledelayedexpansion

set COBBLER_MAC=

{% if winpe_enable_script_debug | bool %}
PAUSE
{% else %}
ping -n 3 127.0.0.1 > NUL
{% endif %}

REM Get the hostname
for /f "tokens=*" %%H in ('hostname') do (
    set COBBLER_HNAME=%%H
    goto :found_hostname
)
:found_hostname

{% if winpe_enable_script_debug | bool %}
PAUSE
{% else %}
ping -n 3 127.0.0.1 > NUL
{% endif %}

REM Get the MAC address from ipconfig output
set MAC_FOUND=false
for /f "tokens=2 delims=:" %%A in ('ipconfig /all ^| find "Physical Address"') do (
    if not "!MAC_FOUND!"=="true" (
        set "COBBLER_MAC=%%A"
        REM Remove leading spaces
        set "COBBLER_MAC=!COBBLER_MAC:~1!"
        set MAC_FOUND=true
    )
)
if "%MAC_FOUND%"=="false" (
    echo MAC Address not found.
    exit /b 1
)

REM Replace hyphens with colons
set COBBLER_MAC=!COBBLER_MAC:-=:!

{% if winpe_enable_script_debug | bool %}
PAUSE
{% else %}
ping -n 3 127.0.0.1 > NUL
{% endif %}

REM Send request to Cobbler server
for /f "delims= " %%S in ('curl -s -H "X-RHN-Provisioning-MAC-0: eth0 %COBBLER_MAC%" http://%COBBLER_SERV%:%COBBLER_PORT%/cblr/svc/op/autodetect') do set COBBLER_SYSNAME=%%S

{% if winpe_enable_script_debug | bool %}
PAUSE
{% else %}
ping -n 3 127.0.0.1 > NUL
{% endif %}

REM Preserve the COBBLER_SYSNAME and COBBLER_MAC variables
endlocal & set COBBLER_SYSNAME=%COBBLER_SYSNAME%& set COBBLER_MAC=%COBBLER_MAC%