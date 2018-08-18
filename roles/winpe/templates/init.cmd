@echo off


set COBBLER_SERV="{{ lookup('env', 'COBBLER_host') | urlsplit('hostname') }}"


rem -------------------------------------------------------------------
rem setup enviroment variables
rem -------------------------------------------------------------------
echo set COBBLER_SYSTEMNAME
echo NEXT: %SYSTEMDRIVE%\opt\bootstrap\setsysname.cmd
PAUSE
call %SYSTEMDRIVE%\opt\bootstrap\setsysname.cmd


rem -------------------------------------------------------------------
rem fetch install script
rem -------------------------------------------------------------------

echo "get the remainder of the init scripts"
echo NEXT: curl -s -o %TEMP%/mountmedia.cmd http://%COBBLER_SERV%/cblr/svc/op/script/system/%COBBLER_SYSNAME%/?script=mountmedia.cmd
PAUSE
curl -s -o %TEMP%/mountmedia.cmd http://%COBBLER_SERV%/cblr/svc/op/script/system/%COBBLER_SYSNAME%/?script=mountmedia.cmd


echo NEXT: curl -s -o %TEMP%/getks.cmd http://%COBBLER_SERV%/cblr/svc/op/script/system/%COBBLER_SYSNAME%/?script=getks.cmd
PAUSE
curl -s -o %TEMP%/getks.cmd http://%COBBLER_SERV%/cblr/svc/op/script/system/%COBBLER_SYSNAME%/?script=getks.cmd


echo NEXT: curl -s -o %TEMP%/runsetup.cmd http://%COBBLER_SERV%/cblr/svc/op/script/system/%COBBLER_SYSNAME%/?script=runsetup.cmd
PAUSE
curl -s -o %TEMP%/runsetup.cmd http://%COBBLER_SERV%/cblr/svc/op/script/system/%COBBLER_SYSNAME%/?script=runsetup.cmd


rem -------------------------------------------------------------------
rem run setup
rem -------------------------------------------------------------------

echo NEXT:call %TEMP%\mountmedia.cmd
PAUSE
call %TEMP%\mountmedia.cmd

echo NEXT:call %TEMP%\getks.cmd
PAUSE
call %TEMP%\getks.cmd

call NEXT:%TEMP%\runsetup.cmd
PAUSE
call %TEMP%\runsetup.cmd
PAUSE


echo FINISH to SETUP
PAUSE