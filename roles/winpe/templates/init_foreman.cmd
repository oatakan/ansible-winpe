@echo off
SETLOCAL EnableDelayedExpansion

:: init_foreman.cmd — Foreman provisioning init script for WinPE
:: Flow:
::   1. Discover own MAC + IP (setsysname_foreman.cmd)
::   2. Download unattend.xml from Foreman /unattended/provision (IP-matched)
::   3. Download rendered mountmedia.cmd from Foreman and map media
::   4. Run setup.exe with /noreboot (Phase 1: partition + image expand only,
::      returns to WinPE without rebooting)
::   5. Find the target Windows partition (scan for \Windows\System32\cmd.exe)
::   6. Write SetupComplete.cmd to target partition — it fires the Foreman built
::      callback after Windows completes all setup phases, before first logon
::      (FOREMAN_TOKEN from mountmedia.cmd is hardcoded at write time)
::   7. Reboot into Windows setup Phase 2+

echo NEXT: %SYSTEMDRIVE%\opt\bootstrap\setsysname_foreman.cmd
{% if winpe_enable_script_debug | bool %}
PAUSE
{% else %}
ping -n 3 127.0.0.1 > NUL
{% endif %}
call %SYSTEMDRIVE%\opt\bootstrap\setsysname_foreman.cmd

echo FOREMAN_PROVISION_URL=%FOREMAN_PROVISION_URL%

:: --------------------------------------------------------------------
:: Step 2: Download unattend.xml from Foreman
:: Foreman matches by source IP — no token needed in WinPE context
:: (requires "Require token for templates" disabled in Foreman settings,
::  OR use curl -k to handle self-signed cert if HTTPS)
:: --------------------------------------------------------------------
echo NEXT: download unattend.xml from Foreman

{% if winpe_enable_script_debug | bool %}
PAUSE
{% else %}
ping -n 3 127.0.0.1 > NUL
{% endif %}
curl -k -s -o %TEMP%\unattend.xml %FOREMAN_PROVISION_URL%
if !ERRORLEVEL! NEQ 0 (
    echo ERROR: Failed to download unattend.xml from Foreman
    exit /b 1
)

{% if winpe_enable_script_debug | bool %}
echo --- unattend.xml contents ---
type %TEMP%\unattend.xml
PAUSE
{% endif %}

:: --------------------------------------------------------------------
:: Step 3: Download mountmedia.cmd from Foreman (dynamic — no hardcoded paths)
:: Foreman renders the 'windows-mountmedia.cmd' script template (kind=script)
:: at /unattended/script, matching this host by source IP.
:: The rendered script contains: net use W: \\host\media\windows\<isoname>
:: derived from @host.medium.path, which Foreman knows from the OS assignment.
::
:: This is the direct Foreman equivalent of cobbler:
::   curl /cblr/svc/op/script/system/%COBBLER_SYSNAME%/?script=mountmedia.cmd
:: (cobbler renders with $server + $distro_name; Foreman renders with @host.medium.path)
::
:: No winpe_foreman_smb_media needed — WinPE ISO is now fully generic.
:: --------------------------------------------------------------------
echo NEXT: download mountmedia.cmd from Foreman

{% if winpe_enable_script_debug | bool %}
PAUSE
{% else %}
ping -n 3 127.0.0.1 > NUL
{% endif %}
curl -k -s -o %TEMP%\mountmedia.cmd %FOREMAN_SCRIPT_URL%
if !ERRORLEVEL! NEQ 0 (
    echo ERROR: Failed to download mountmedia.cmd from %FOREMAN_SCRIPT_URL%
    exit /b 1
)

{% if winpe_enable_script_debug | bool %}
echo --- mountmedia.cmd contents (rendered by Foreman) ---
type %TEMP%\mountmedia.cmd
PAUSE
{% endif %}

echo NEXT: call %TEMP%\mountmedia.cmd
{% if winpe_enable_script_debug | bool %}
PAUSE
{% else %}
ping -n 3 127.0.0.1 > NUL
{% endif %}
call %TEMP%\mountmedia.cmd
if !ERRORLEVEL! NEQ 0 (
    echo ERROR: mountmedia.cmd failed - Windows media not mounted
    exit /b 1
)
:: FOREMAN_MEDIA is set by mountmedia.cmd (e.g. W:)
set MEDIA_DRIVE=%FOREMAN_MEDIA%
:: FOREMAN_TOKEN is also set by mountmedia.cmd (rendered by Foreman).
:: It is embedded into SetupComplete.cmd at write time (Step 6).

:: --------------------------------------------------------------------
:: Step 4: Run Windows setup with /noreboot
:: setup.exe Phase 1: partition disk + expand Windows image + bootloader setup
:: Returns to WinPE after Phase 1 without rebooting, so we can inject
:: SetupComplete.cmd before the machine boots into Windows Phase 2.
::
:: EMS (/emsport:COM1) is gated by winpe_foreman_ems_enabled (default: false).
:: When EMS is enabled, Windows Boot Manager shows a text-mode menu requiring
:: manual selection of "Windows Server [EMS Enabled]". Leave disabled for
:: fully automated provisioning.
:: --------------------------------------------------------------------
echo NEXT: run Windows setup Phase 1 ^(with /noreboot^)

{% if winpe_enable_script_debug | bool %}
echo 30 seconds before starting setup - close window to cancel
PAUSE
{% else %}
ping -n 31 127.0.0.1 > NUL
{% endif %}
%MEDIA_DRIVE%\setup.exe /unattend:%TEMP%\unattend.xml{% if winpe_foreman_ems_enabled | bool %} /emsport:COM1 /emsbaudrate:115200{% endif %} /noreboot
set SETUP_EXIT=!ERRORLEVEL!
:: setup.exe /noreboot returns 3010 (reboot required) on success — treat as OK
if !SETUP_EXIT! NEQ 0 if !SETUP_EXIT! NEQ 3010 (
    echo ERROR: setup.exe failed with errorlevel !SETUP_EXIT!
    exit /b !SETUP_EXIT!
)
echo setup.exe Phase 1 complete ^(exitcode=!SETUP_EXIT!^)

{% if winpe_foreman_setupcomplete_in_winpe | bool %}
:: --------------------------------------------------------------------
:: Step 5: Find the target Windows partition
:: After Phase 1, setup.exe has expanded the image to the target disk.
:: Scan drive letters (excluding X: WinPE RAM disk) for \Windows\System32\cmd.exe
:: --------------------------------------------------------------------
echo NEXT: locate target Windows partition
set TARGET_DRIVE=
for %%D in (C D E F G H I J K L) do (
    if exist %%D:\Windows\System32\cmd.exe (
        set TARGET_DRIVE=%%D:
        goto :found_target
    )
)
echo ERROR: Could not find target Windows partition after setup.exe Phase 1
exit /b 1
:found_target
echo Found target Windows partition: !TARGET_DRIVE!

:: --------------------------------------------------------------------
:: Step 6: Write SetupComplete.cmd to target Windows partition
:: SetupComplete.cmd is run automatically after all Windows setup phases
:: (Specialize/OobeSystem) complete, immediately before first user logon.
::
:: FOREMAN_BUILT_URL and FOREMAN_TOKEN are hardcoded now (WinPE values)
:: so SetupComplete.cmd is fully self-contained with no runtime dependencies.
:: --------------------------------------------------------------------
echo NEXT: write SetupComplete.cmd to !TARGET_DRIVE!\Windows\Setup\Scripts\
set SETUP_SCRIPTS_DIR=!TARGET_DRIVE!\Windows\Setup\Scripts
mkdir "!SETUP_SCRIPTS_DIR!" 2>NUL
set SETUP_COMPLETE=!SETUP_SCRIPTS_DIR!\SetupComplete.cmd

if "%FOREMAN_TOKEN%"=="" (
    echo ERROR: FOREMAN_TOKEN is empty; cannot write SetupComplete.cmd
    exit /b 1
)

:: Write SetupComplete.cmd line by line.
:: !FOREMAN_BUILT_URL! and !FOREMAN_TOKEN! expand now (hardcoded into output).
:: %%VARIABLE%% in echo becomes %VARIABLE% in the output file.
:: ^> in echo becomes > in the output file.
echo @echo off>"!SETUP_COMPLETE!"
echo :: SetupComplete.cmd — Foreman built callback>>"!SETUP_COMPLETE!"
echo :: Written by WinPE init_foreman.cmd; fires after Windows setup completes>>"!SETUP_COMPLETE!"
echo set MAX_RETRIES={{ winpe_foreman_built_callback_retries | default(10) }}>>"!SETUP_COMPLETE!"
echo set DELAY_SEC={{ winpe_foreman_built_callback_retry_delay_sec | default(15) }}>>"!SETUP_COMPLETE!"
echo set RETRY=0>>"!SETUP_COMPLETE!"
echo :retry>>"!SETUP_COMPLETE!"
echo curl -k -s -o NUL -X POST "!FOREMAN_BUILT_URL!?token=!FOREMAN_TOKEN!">>"!SETUP_COMPLETE!"
echo if %%ERRORLEVEL%% EQU 0 ^( echo Foreman built callback ok. ^& goto :done ^)>>"!SETUP_COMPLETE!"
echo set /a RETRY+=1>>"!SETUP_COMPLETE!"
echo if %%RETRY%% GEQ %%MAX_RETRIES%% goto :done>>"!SETUP_COMPLETE!"
echo ping -n %%DELAY_SEC%% 127.0.0.1 ^> NUL>>"!SETUP_COMPLETE!"
echo goto :retry>>"!SETUP_COMPLETE!"
echo :done>>"!SETUP_COMPLETE!"
{% if winpe_foreman_disable_ems_in_bcd | bool %}
echo :: Disable EMS in BCD to prevent text-mode Windows Boot Manager menu>>"!SETUP_COMPLETE!"
echo bcdedit /set {current} bootems no>>"!SETUP_COMPLETE!"
echo bcdedit /set {bootmgr} displaybootmenu no>>"!SETUP_COMPLETE!"
{% endif %}
echo exit /b 0>>"!SETUP_COMPLETE!"

if !ERRORLEVEL! NEQ 0 (
    echo ERROR: Failed to write SetupComplete.cmd
    exit /b 1
)
echo SetupComplete.cmd written successfully

{% if winpe_enable_script_debug | bool %}
echo --- SetupComplete.cmd contents ---
type "!SETUP_COMPLETE!"
PAUSE
{% endif %}
{% endif %}

:: --------------------------------------------------------------------
:: Step 7: POST /unattended/built from WinPE BEFORE rebooting.
:: This sets build=false in Foreman so that when the VM reboots and iPXE
:: runs, Foreman serves the chainload-to-disk script instead of WinPE again.
:: (SetupComplete.cmd will also attempt the callback after full install —
::  that duplicate call is harmless; Foreman returns 200 OK.)
:: --------------------------------------------------------------------
if "%FOREMAN_TOKEN%"=="" (
    echo ERROR: FOREMAN_TOKEN is empty; cannot call /unattended/built
    exit /b 1
)

set BUILT_CALLBACK_URL=%FOREMAN_BUILT_URL%?token=%FOREMAN_TOKEN%
set CALLBACK_MAX_RETRIES={{ winpe_foreman_built_callback_retries | default(10) }}
set CALLBACK_DELAY_SEC={{ winpe_foreman_built_callback_retry_delay_sec | default(15) }}
set CALLBACK_TRY=1

:built_callback_retry
if !CALLBACK_TRY! GTR !CALLBACK_MAX_RETRIES! (
    echo ERROR: Foreman built callback failed after !CALLBACK_MAX_RETRIES! attempts
    exit /b 1
)
echo Attempting Foreman built callback ^(try !CALLBACK_TRY!/!CALLBACK_MAX_RETRIES!^): !BUILT_CALLBACK_URL!
curl -k -s -f -o NUL -X POST "!BUILT_CALLBACK_URL!"
if !ERRORLEVEL! EQU 0 (
    echo Foreman built callback succeeded.
) else (
    echo WARN: Foreman built callback failed on try !CALLBACK_TRY!, retrying in !CALLBACK_DELAY_SEC!s...
    set /a CALLBACK_TRY+=1
    ping -n !CALLBACK_DELAY_SEC! 127.0.0.1 > NUL
    goto :built_callback_retry
)

:: --------------------------------------------------------------------
:: Step 8: Reboot into Windows setup Phase 2+
:: Foreman now has build=false so iPXE will chainload the disk EFI bootloader
:: instead of serving WinPE again. Windows Phase 2/3/4 setup runs, then
:: SetupComplete.cmd fires a confirmation callback (build already false — OK).
:: --------------------------------------------------------------------
echo Rebooting into Windows setup Phase 2...
{% if winpe_enable_script_debug | bool %}
PAUSE
{% endif %}
wpeutil reboot

echo FINISH WinPE flow completed
exit
