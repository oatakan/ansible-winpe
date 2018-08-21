Dism /Mount-Image /ImageFile:"C:\{{ winpe_name }}\media\sources\boot.wim" /Index:1 /MountDir:"C:\{{ winpe_name }}\mount"

{% if enable_powershell_modules %}
Dism /Add-Package /Image:"C:\{{ winpe_name }}\mount" /PackagePath:"c:\ADK\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\WinPE-WMI.cab"
Dism /Add-Package /Image:"C:\{{ winpe_name }}\mount" /PackagePath:"c:\ADK\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\en-us\WinPE-WMI_en-us.cab"
Dism /Add-Package /Image:"C:\{{ winpe_name }}\mount" /PackagePath:"c:\ADK\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\WinPE-NetFX.cab"
Dism /Add-Package /Image:"C:\{{ winpe_name }}\mount" /PackagePath:"c:\ADK\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\en-us\WinPE-NetFX_en-us.cab"
Dism /Add-Package /Image:"C:\{{ winpe_name }}\mount" /PackagePath:"c:\ADK\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\WinPE-Scripting.cab"
Dism /Add-Package /Image:"C:\{{ winpe_name }}\mount" /PackagePath:"c:\ADK\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\en-us\WinPE-Scripting_en-us.cab"
Dism /Add-Package /Image:"C:\{{ winpe_name }}\mount" /PackagePath:"c:\ADK\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\WinPE-PowerShell.cab"
Dism /Add-Package /Image:"C:\{{ winpe_name }}\mount" /PackagePath:"c:\ADK\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\en-us\WinPE-PowerShell_en-us.cab"
Dism /Add-Package /Image:"C:\{{ winpe_name }}\mount" /PackagePath:"c:\ADK\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\WinPE-StorageWMI.cab"
Dism /Add-Package /Image:"C:\{{ winpe_name }}\mount" /PackagePath:"c:\ADK\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\en-us\WinPE-StorageWMI_en-us.cab"
Dism /Add-Package /Image:"C:\{{ winpe_name }}\mount" /PackagePath:"c:\ADK\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\WinPE-DismCmdlets.cab"
Dism /Add-Package /Image:"C:\{{ winpe_name }}\mount" /PackagePath:"c:\ADK\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\en-us\WinPE-DismCmdlets_en-us.cab"
{% endif %}

Copy-Item "{{ temp_directory }}\\winpeshl.ini" -Destination "C:\{{ winpe_name }}\mount\Windows\system32"
Copy-Item "{{ temp_directory }}\\curl-7.61.0-win64-mingw\\bin\*" -Destination "C:\{{ winpe_name }}\mount\Windows\system32"

md "C:\{{ winpe_name }}\mount\opt\bootstrap" -ea 0

Copy-Item "{{ temp_directory }}\\init.cmd" -Destination "C:\{{ winpe_name }}\mount\opt\bootstrap"
Copy-Item "{{ temp_directory }}\\setsysname.cmd" -Destination "C:\{{ winpe_name }}\mount\opt\bootstrap"

Copy-Item C:\Windows\System32\timeout.exe -Destination "C:\{{ winpe_name }}\mount\Windows\system32"

{% if load_drivers %}
md "C:\\{{ winpe_name }}\\mount\\drivers" -ea 0
# Load drivers
{% for driver in drivers %}
Move-Item -Path "C:\\{{ temp_directory }}\\{{ driver.name }}" -Destination "C:\\{{ winpe_name }}\\mount\\drivers"
Dism /Image:"C:\{{ winpe_name }}\mount" /Add-Driver /Driver:"C:\\{{ winpe_name }}\\mount\\drivers\\{{ driver.name }}" /Recurse
{% endfor %}
{% endif %}

Dism /Unmount-Image /MountDir:C:\{{ winpe_name }}\mount /Commit