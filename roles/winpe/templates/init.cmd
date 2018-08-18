@echo off


set COBBLER_SERV={{ lookup('env', 'COBBLER_host') | urlsplit('hostname') }}
set COBBLER_PORT={{ cobbler_port }}


rem -------------------------------------------------------------------
rem setup enviroment variables
rem -------------------------------------------------------------------
echo set COBBLER_SYSTEMNAME
echo NEXT: %SYSTEMDRIVE%\opt\bootstrap\setsysname.cmd
{% if enable_script_debug %}
PAUSE
{% endif %}
call %SYSTEMDRIVE%\opt\bootstrap\setsysname.cmd


rem -------------------------------------------------------------------
rem fetch install script
rem -------------------------------------------------------------------

echo "get the remainder of the init scripts"
echo NEXT: curl -s -o %TEMP%/mountmedia.cmd http://%COBBLER_SERV%:%COBBLER_PORT%/cblr/svc/op/script/system/%COBBLER_SYSNAME%/?script=mountmedia.cmd
{% if enable_script_debug %}
PAUSE
{% endif %}
curl -s -o %TEMP%/mountmedia.cmd http://%COBBLER_SERV%:%COBBLER_PORT%/cblr/svc/op/script/system/%COBBLER_SYSNAME%/?script=mountmedia.cmd


echo NEXT: curl -s -o %TEMP%/getks.cmd http://%COBBLER_SERV%:%COBBLER_PORT%/cblr/svc/op/script/system/%COBBLER_SYSNAME%/?script=getks.cmd
{% if enable_script_debug %}
PAUSE
{% endif %}
curl -s -o %TEMP%/getks.cmd http://%COBBLER_SERV%:%COBBLER_PORT%/cblr/svc/op/script/system/%COBBLER_SYSNAME%/?script=getks.cmd


echo NEXT: curl -s -o %TEMP%/runsetup.cmd http://%COBBLER_SERV%:%COBBLER_PORT%/cblr/svc/op/script/system/%COBBLER_SYSNAME%/?script=runsetup.cmd
{% if enable_script_debug %}
PAUSE
{% endif %}
curl -s -o %TEMP%/runsetup.cmd http://%COBBLER_SERV%:%COBBLER_PORT%/cblr/svc/op/script/system/%COBBLER_SYSNAME%/?script=runsetup.cmd

echo NEXT: curl -s -o %TEMP%/runsetup.cmd http://%COBBLER_SERV%:%COBBLER_PORT%/cblr/svc/op/script/system/%COBBLER_SYSNAME%/?script=setupcomplete.cmd
{% if enable_script_debug %}
PAUSE
{% endif %}
curl -s -o %TEMP%/setupcomplete.cmd http://%COBBLER_SERV%:%COBBLER_PORT%/cblr/svc/op/script/system/%COBBLER_SYSNAME%/?script=setupcomplete.cmd


rem -------------------------------------------------------------------
rem run setup
rem -------------------------------------------------------------------

echo NEXT:call %TEMP%\mountmedia.cmd
{% if enable_script_debug %}
PAUSE
{% endif %}
call %TEMP%\mountmedia.cmd

echo NEXT:call %TEMP%\getks.cmd
{% if enable_script_debug %}
PAUSE
{% endif %}
call %TEMP%\getks.cmd

echo NEXT:call %TEMP%\setupcomplete.cmd
{% if enable_script_debug %}
PAUSE
{% endif %}
call %TEMP%\setupcomplete.cmd
{% if enable_script_debug %}
PAUSE
{% endif %}

echo NEXT:call %TEMP%\runsetup.cmd
{% if enable_script_debug %}
PAUSE
{% endif %}
call %TEMP%\runsetup.cmd
{% if enable_script_debug %}
PAUSE
{% endif %}

echo FINISH to SETUP
{% if enable_script_debug %}
PAUSE
{% endif %}
