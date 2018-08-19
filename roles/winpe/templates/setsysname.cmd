@echo on

set COBBLER_MAC=

{% if enable_script_debug %}
PAUSE
{% else %}
timeout /t 2 /nobreak > NUL
{% endif %}
for /f "tokens=1 delims= "    %%H in ('nbtstat -n ^| find "UNIQUE"')                      do set COBBLER_HNAME=%%H
{% if enable_script_debug %}
PAUSE
{% else %}
timeout /t 2 /nobreak > NUL
{% endif %}
for /f "tokens=4 delims= "    %%M in ('nbtstat -a %COBBLER_HNAME% ^| find "MAC Address"') do set COBBLER_MAC=%%M
{% if enable_script_debug %}
PAUSE
{% else %}
timeout /t 2 /nobreak > NUL
{% endif %}
for /f "tokens=1-6 delims=- " %%a in ('echo %COBBLER_MAC%')                               do set COBBLER_MAC=%%a:%%b:%%c:%%d:%%e:%%f

{% if enable_script_debug %}
PAUSE
{% else %}
timeout /t 2 /nobreak > NUL
{% endif %}
for /f "delims= " %%S in ('curl -s -H "X-RHN-Provisioning-MAC-0: eth0 %COBBLER_MAC%" http://%COBBLER_SERV%:%COBBLER_PORT%/cblr/svc/op/autodetect') do set COBBLER_SYSNAME=%%S