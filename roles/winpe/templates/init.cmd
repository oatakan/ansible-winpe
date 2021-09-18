@echo off

SETLOCAL EnableDelayedExpansion

set COBBLER_SERV={{ cobbler_host }}
set COBBLER_PORT={{ cobbler_port }}


rem -------------------------------------------------------------------
rem setup enviroment variables
rem -------------------------------------------------------------------
echo set COBBLER_SYSTEMNAME
echo NEXT: %SYSTEMDRIVE%\opt\bootstrap\setsysname.cmd
{% if enable_script_debug %}
PAUSE
{% else %}
timeout /t 2 /nobreak > NUL
{% endif %}
call %SYSTEMDRIVE%\opt\bootstrap\setsysname.cmd


rem -------------------------------------------------------------------
rem fetch install script
rem -------------------------------------------------------------------

echo "get the remainder of the init scripts"
echo NEXT: curl -s -o %TEMP%/mountmedia.cmd http://%COBBLER_SERV%:%COBBLER_PORT%/cblr/svc/op/script/system/%COBBLER_SYSNAME%/?script=mountmedia.cmd
{% if enable_script_debug %}
PAUSE
{% else %}
timeout /t 2 /nobreak > NUL
{% endif %}
curl -s -o %TEMP%/mountmedia.cmd http://%COBBLER_SERV%:%COBBLER_PORT%/cblr/svc/op/script/system/%COBBLER_SYSNAME%/?script=mountmedia.cmd


echo NEXT: curl -s -o %TEMP%/getks.cmd http://%COBBLER_SERV%:%COBBLER_PORT%/cblr/svc/op/script/system/%COBBLER_SYSNAME%/?script=getks.cmd
{% if enable_script_debug %}
PAUSE
{% else %}
timeout /t 2 /nobreak > NUL
{% endif %}
curl -s -o %TEMP%/getks.cmd http://%COBBLER_SERV%:%COBBLER_PORT%/cblr/svc/op/script/system/%COBBLER_SYSNAME%/?script=getks.cmd


echo NEXT: curl -s -o %TEMP%/runsetup.cmd http://%COBBLER_SERV%:%COBBLER_PORT%/cblr/svc/op/script/system/%COBBLER_SYSNAME%/?script=runsetup.cmd
{% if enable_script_debug %}
PAUSE
{% else %}
timeout /t 2 /nobreak > NUL
{% endif %}
curl -s -o %TEMP%/runsetup.cmd http://%COBBLER_SERV%:%COBBLER_PORT%/cblr/svc/op/script/system/%COBBLER_SYSNAME%/?script=runsetup.cmd

echo NEXT: curl -s -o %TEMP%/runsetup.cmd http://%COBBLER_SERV%:%COBBLER_PORT%/cblr/svc/op/script/system/%COBBLER_SYSNAME%/?script=setupcomplete.cmd
{% if enable_script_debug %}
PAUSE
{% else %}
timeout /t 2 /nobreak > NUL
{% endif %}
curl -s -o %TEMP%/setupcomplete.cmd http://%COBBLER_SERV%:%COBBLER_PORT%/cblr/svc/op/script/system/%COBBLER_SYSNAME%/?script=setupcomplete.cmd


rem -------------------------------------------------------------------
rem run setup
rem -------------------------------------------------------------------

echo NEXT:call %TEMP%\mountmedia.cmd
{% if enable_script_debug %}
PAUSE
{% else %}
timeout /t 2 /nobreak > NUL
{% endif %}
call %TEMP%\mountmedia.cmd
if !ERRORLEVEL! NEQ 0 exit

echo NEXT:call %TEMP%\getks.cmd
{% if enable_script_debug %}
PAUSE
{% else %}
timeout /t 2 /nobreak > NUL
{% endif %}
call %TEMP%\getks.cmd

echo NEXT:call %TEMP%\runsetup.cmd
{% if enable_script_debug %}
PAUSE
{% else %}
echo waiting for 30 seconds before installing Windows, close this window if you want to cancel
timeout /t 30 /nobreak > NUL
{% endif %}
call %TEMP%\runsetup.cmd
if !ERRORLEVEL! NEQ 0 exit
{% if enable_script_debug %}
PAUSE
{% else %}
timeout /t 2 /nobreak > NUL
{% endif %}

echo NEXT:call %TEMP%\setupcomplete.cmd
{% if enable_script_debug %}
PAUSE
{% else %}
timeout /t 2 /nobreak > NUL
{% endif %}
call %TEMP%\setupcomplete.cmd
{% if enable_script_debug %}
PAUSE
{% else %}
timeout /t 2 /nobreak > NUL
{% endif %}

echo FINISH to SETUP
{% if enable_script_debug %}
PAUSE
{% else %}
timeout /t 2 /nobreak > NUL
{% endif %}
exit