Dism /Mount-Image /ImageFile:"C:\WinPE_amd64_PS\media\sources\boot.wim" /Index:1 /MountDir:"C:\WinPE_amd64_PS\mount"
Dism /Add-Package /Image:"C:\WinPE_amd64_PS\mount" /PackagePath:"c:\ADK\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\WinPE-WMI.cab"
Dism /Add-Package /Image:"C:\WinPE_amd64_PS\mount" /PackagePath:"c:\ADK\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\en-us\WinPE-WMI_en-us.cab"
Dism /Add-Package /Image:"C:\WinPE_amd64_PS\mount" /PackagePath:"c:\ADK\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\WinPE-NetFX.cab"
Dism /Add-Package /Image:"C:\WinPE_amd64_PS\mount" /PackagePath:"c:\ADK\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\en-us\WinPE-NetFX_en-us.cab"
Dism /Add-Package /Image:"C:\WinPE_amd64_PS\mount" /PackagePath:"c:\ADK\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\WinPE-Scripting.cab"
Dism /Add-Package /Image:"C:\WinPE_amd64_PS\mount" /PackagePath:"c:\ADK\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\en-us\WinPE-Scripting_en-us.cab"
Dism /Add-Package /Image:"C:\WinPE_amd64_PS\mount" /PackagePath:"c:\ADK\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\WinPE-PowerShell.cab"
Dism /Add-Package /Image:"C:\WinPE_amd64_PS\mount" /PackagePath:"c:\ADK\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\en-us\WinPE-PowerShell_en-us.cab"
Dism /Add-Package /Image:"C:\WinPE_amd64_PS\mount" /PackagePath:"c:\ADK\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\WinPE-StorageWMI.cab"
Dism /Add-Package /Image:"C:\WinPE_amd64_PS\mount" /PackagePath:"c:\ADK\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\en-us\WinPE-StorageWMI_en-us.cab"
Dism /Add-Package /Image:"C:\WinPE_amd64_PS\mount" /PackagePath:"c:\ADK\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\WinPE-DismCmdlets.cab"
Dism /Add-Package /Image:"C:\WinPE_amd64_PS\mount" /PackagePath:"c:\ADK\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\en-us\WinPE-DismCmdlets_en-us.cab"

Copy-Item "{{ temp_directory }}\\winpeshl.ini" -Destination "C:\WinPE_amd64_PS\mount\Windows\system32"
Copy-Item "{{ temp_directory }}\\curl-7.61.0-win64-mingw\\bin\*" -Destination "C:\WinPE_amd64_PS\mount\Windows\system32"

Dism /Unmount-Image /MountDir:C:\WinPE_amd64_PS\mount /Commit