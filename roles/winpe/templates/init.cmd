@echo off

SETLOCAL EnableDelayedExpansion

set COBBLER_SERV={{ winpe_cobbler_host }}
set COBBLER_PORT={{ winpe_cobbler_port }}


rem -------------------------------------------------------------------
rem setup environment variables
rem -------------------------------------------------------------------
echo set COBBLER_SYSTEMNAME
echo NEXT: %SYSTEMDRIVE%\opt\bootstrap\setsysname.cmd
{% if winpe_enable_script_debug | bool %}
PAUSE
{% else %}
ping -n 3 127.0.0.1 > NUL
{% endif %}
call %SYSTEMDRIVE%\opt\bootstrap\setsysname.cmd


rem -------------------------------------------------------------------
rem fetch install script
rem -------------------------------------------------------------------

echo "get the remainder of the init scripts"
echo NEXT: curl -s -o %TEMP%/mountmedia.cmd http://%COBBLER_SERV%:%COBBLER_PORT%/cblr/svc/op/script/system/%COBBLER_SYSNAME%/?script=mountmedia.cmd
{% if winpe_enable_script_debug | bool %}
PAUSE
{% else %}
ping -n 3 127.0.0.1 > NUL
{% endif %}
curl -s -o %TEMP%/mountmedia.cmd http://%COBBLER_SERV%:%COBBLER_PORT%/cblr/svc/op/script/system/%COBBLER_SYSNAME%/?script=mountmedia.cmd


echo NEXT: curl -s -o %TEMP%/getks.cmd http://%COBBLER_SERV%:%COBBLER_PORT%/cblr/svc/op/script/system/%COBBLER_SYSNAME%/?script=getks.cmd
{% if winpe_enable_script_debug | bool %}
PAUSE
{% else %}
ping -n 3 127.0.0.1 > NUL
{% endif %}
curl -s -o %TEMP%/getks.cmd http://%COBBLER_SERV%:%COBBLER_PORT%/cblr/svc/op/script/system/%COBBLER_SYSNAME%/?script=getks.cmd


echo NEXT: curl -s -o %TEMP%/runsetup.cmd http://%COBBLER_SERV%:%COBBLER_PORT%/cblr/svc/op/script/system/%COBBLER_SYSNAME%/?script=runsetup.cmd
{% if winpe_enable_script_debug | bool %}
PAUSE
{% else %}
ping -n 3 127.0.0.1 > NUL
{% endif %}
curl -s -o %TEMP%/runsetup.cmd http://%COBBLER_SERV%:%COBBLER_PORT%/cblr/svc/op/script/system/%COBBLER_SYSNAME%/?script=runsetup.cmd

echo NEXT: curl -s -o %TEMP%/runsetup.cmd http://%COBBLER_SERV%:%COBBLER_PORT%/cblr/svc/op/script/system/%COBBLER_SYSNAME%/?script=setupcomplete.cmd
{% if winpe_enable_script_debug | bool %}
PAUSE
{% else %}
ping -n 3 127.0.0.1 > NUL
{% endif %}
curl -s -o %TEMP%/setupcomplete.cmd http://%COBBLER_SERV%:%COBBLER_PORT%/cblr/svc/op/script/system/%COBBLER_SYSNAME%/?script=setupcomplete.cmd


rem -------------------------------------------------------------------
rem run setup
rem -------------------------------------------------------------------

echo NEXT:call %TEMP%\mountmedia.cmd
{% if winpe_enable_script_debug | bool %}
PAUSE
{% else %}
ping -n 3 127.0.0.1 > NUL
{% endif %}
call %TEMP%\mountmedia.cmd
if !ERRORLEVEL! NEQ 0 exit

echo NEXT:call %TEMP%\getks.cmd
{% if winpe_enable_script_debug | bool %}
PAUSE
{% else %}
ping -n 3 127.0.0.1 > NUL
{% endif %}
call %TEMP%\getks.cmd

echo NEXT:call %TEMP%\runsetup.cmd
{% if winpe_enable_script_debug | bool %}
PAUSE
{% else %}
echo waiting for 30 seconds before installing Windows, close this window if you want to cancel
ping -n 31 127.0.0.1 > NUL
{% endif %}
call %TEMP%\runsetup.cmd
if !ERRORLEVEL! NEQ 0 exit
{% if winpe_enable_script_debug | bool %}
PAUSE
{% else %}
ping -n 3 127.0.0.1 > NUL
{% endif %}

echo NEXT:call %TEMP%\setupcomplete.cmd
{% if winpe_enable_script_debug | bool %}
PAUSE
{% else %}
ping -n 3 127.0.0.1 > NUL
{% endif %}
call %TEMP%\setupcomplete.cmd
{% if winpe_enable_script_debug | bool %}
PAUSE
{% else %}
ping -n 3 127.0.0.1 > NUL
{% endif %}

echo FINISH to SETUP
{% if winpe_enable_script_debug | bool %}
PAUSE
{% else %}
ping -n 3 127.0.0.1 > NUL
{% endif %}
exit