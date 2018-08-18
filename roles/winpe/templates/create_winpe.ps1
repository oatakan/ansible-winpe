Dism /Mount-Image /ImageFile:"C:\{{ winpe_name }}\media\sources\boot.wim" /Index:1 /MountDir:"C:\{{ winpe_name }}\mount"
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

Copy-Item "{{ temp_directory }}\\winpeshl.ini" -Destination "C:\{{ winpe_name }}\mount\Windows\system32"
Copy-Item "{{ temp_directory }}\\curl-7.61.0-win64-mingw\\bin\*" -Destination "C:\{{ winpe_name }}\mount\Windows\system32"

md "C:\{{ winpe_name }}\mount\opt\bootstrap" -ea 0

Copy-Item "{{ temp_directory }}\\init.cmd" -Destination "C:\{{ winpe_name }}\mount\opt\bootstrap"
Copy-Item "{{ temp_directory }}\\setsysname.cmd" -Destination "C:\{{ winpe_name }}\mount\opt\bootstrap"

Dism /Unmount-Image /MountDir:C:\{{ winpe_name }}\mount /Commit