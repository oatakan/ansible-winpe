@echo on

set COBBLER_MAC=

PAUSE
for /f "tokens=1 delims= "    %%H in ('nbtstat -n ^| find "UNIQUE"')                      do set COBBLER_HNAME=%%H
PAUSE
for /f "tokens=4 delims= "    %%M in ('nbtstat -a %COBBLER_HNAME% ^| find "MAC Address"') do set COBBLER_MAC=%%M
PAUSE
for /f "tokens=1-6 delims=- " %%a in ('echo %COBBLER_MAC%')                               do set COBBLER_MAC=%%a:%%b:%%c:%%d:%%e:%%f

PAUSE
for /f "delims= " %%S in ('curl -s http://%COBBLER_SERV%:%COBBLER_PORT%/cblr/svc/op/autodetect/HTTP_X_RHN_PROVISIONING_MAC_0/eth0%20%COBBLER_MAC%') do set COBBLER_SYSNAME=%%S