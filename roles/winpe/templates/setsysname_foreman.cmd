@echo off
::
:: setsysname_foreman.cmd
:: Foreman variant of setsysname.cmd.
:: Discovers own MAC and IP; these are used to build the provision URL.
:: Foreman identifies hosts by source IP (no separate "system name" concept).
::

setlocal enabledelayedexpansion

set FOREMAN_HOST={{ winpe_foreman_host }}
set FOREMAN_PORT={{ winpe_foreman_port }}
set FOREMAN_SCHEME={{ winpe_foreman_scheme }}

{% if winpe_enable_script_debug | bool %}
PAUSE
{% else %}
ping -n 3 127.0.0.1 > NUL
{% endif %}

:: Get MAC address (first NIC, same logic as setsysname.cmd)
set MAC_FOUND=false
for /f "tokens=2 delims=:" %%A in ('ipconfig /all ^| find "Physical Address"') do (
    if not "!MAC_FOUND!"=="true" (
        set "FOREMAN_MAC=%%A"
        set "FOREMAN_MAC=!FOREMAN_MAC:~1!"
        set MAC_FOUND=true
    )
)
if "%MAC_FOUND%"=="false" (
    echo ERROR: MAC Address not found.
    exit /b 1
)
set FOREMAN_MAC=!FOREMAN_MAC:-=:!

{% if winpe_enable_script_debug | bool %}
PAUSE
{% else %}
ping -n 3 127.0.0.1 > NUL
{% endif %}

:: Get own IP address
for /f "tokens=2 delims=:" %%I in ('ipconfig ^| find "IPv4"') do (
    set "FOREMAN_IP=%%I"
    set "FOREMAN_IP=!FOREMAN_IP:~1!"
    goto :ip_found
)
:ip_found

{% if winpe_enable_script_debug | bool %}
echo FOREMAN_MAC=%FOREMAN_MAC%
echo FOREMAN_IP=%FOREMAN_IP%
PAUSE
{% endif %}

::  Build provision URL. Foreman matches by source IP when build=true.
:: No "system name" needed — Foreman returns the unattend.xml directly.
set FOREMAN_PROVISION_URL=%FOREMAN_SCHEME%://%FOREMAN_HOST%/unattended/provision
set FOREMAN_BUILT_URL=%FOREMAN_SCHEME%://%FOREMAN_HOST%/unattended/built
:: Script URL: Foreman renders a host-specific script template (kind=script)
:: matched by source IP — equivalent to cobbler's /cblr/svc/op/script/system/<sysname>/?script=xxx
set FOREMAN_SCRIPT_URL=%FOREMAN_SCHEME%://%FOREMAN_HOST%/unattended/script

endlocal& set FOREMAN_MAC=%FOREMAN_MAC%& set FOREMAN_IP=%FOREMAN_IP%& set FOREMAN_PROVISION_URL=%FOREMAN_PROVISION_URL%& set FOREMAN_BUILT_URL=%FOREMAN_BUILT_URL%& set FOREMAN_SCRIPT_URL=%FOREMAN_SCRIPT_URL%
