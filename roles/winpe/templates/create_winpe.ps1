$mountDir = "C:\{{ winpe_name }}\mount"
Dism /Mount-Image /ImageFile:"C:\{{ winpe_name }}\media\sources\boot.wim" /Index:1 /MountDir:$mountDir

{% if winpe_enable_powershell_modules | bool %}
Dism /Add-Package /Image:$mountDir /PackagePath:"c:\ADK\Assessment and Deployment Kit\Windows Preinstallation Environment\{{ winpe_arch }}\WinPE_OCs\WinPE-WMI.cab"
Dism /Add-Package /Image:$mountDir /PackagePath:"c:\ADK\Assessment and Deployment Kit\Windows Preinstallation Environment\{{ winpe_arch }}\WinPE_OCs\en-us\WinPE-WMI_en-us.cab"
Dism /Add-Package /Image:$mountDir /PackagePath:"c:\ADK\Assessment and Deployment Kit\Windows Preinstallation Environment\{{ winpe_arch }}\WinPE_OCs\WinPE-NetFX.cab"
Dism /Add-Package /Image:$mountDir /PackagePath:"c:\ADK\Assessment and Deployment Kit\Windows Preinstallation Environment\{{ winpe_arch }}\WinPE_OCs\en-us\WinPE-NetFX_en-us.cab"
Dism /Add-Package /Image:$mountDir /PackagePath:"c:\ADK\Assessment and Deployment Kit\Windows Preinstallation Environment\{{ winpe_arch }}\WinPE_OCs\WinPE-Scripting.cab"
Dism /Add-Package /Image:$mountDir /PackagePath:"c:\ADK\Assessment and Deployment Kit\Windows Preinstallation Environment\{{ winpe_arch }}\WinPE_OCs\en-us\WinPE-Scripting_en-us.cab"
Dism /Add-Package /Image:$mountDir /PackagePath:"c:\ADK\Assessment and Deployment Kit\Windows Preinstallation Environment\{{ winpe_arch }}\WinPE_OCs\WinPE-PowerShell.cab"
Dism /Add-Package /Image:$mountDir /PackagePath:"c:\ADK\Assessment and Deployment Kit\Windows Preinstallation Environment\{{ winpe_arch }}\WinPE_OCs\en-us\WinPE-PowerShell_en-us.cab"
Dism /Add-Package /Image:$mountDir /PackagePath:"c:\ADK\Assessment and Deployment Kit\Windows Preinstallation Environment\{{ winpe_arch }}\WinPE_OCs\WinPE-StorageWMI.cab"
Dism /Add-Package /Image:$mountDir /PackagePath:"c:\ADK\Assessment and Deployment Kit\Windows Preinstallation Environment\{{ winpe_arch }}\WinPE_OCs\en-us\WinPE-StorageWMI_en-us.cab"
Dism /Add-Package /Image:$mountDir /PackagePath:"c:\ADK\Assessment and Deployment Kit\Windows Preinstallation Environment\{{ winpe_arch }}\WinPE_OCs\WinPE-DismCmdlets.cab"
Dism /Add-Package /Image:$mountDir /PackagePath:"c:\ADK\Assessment and Deployment Kit\Windows Preinstallation Environment\{{ winpe_arch }}\WinPE_OCs\en-us\WinPE-DismCmdlets_en-us.cab"
{% endif %}

{% if winpe_enable_autostart %}
Copy-Item "{{ winpe_temp_directory }}\winpeshl.ini" -Destination "$mountDir\Windows\system32"
{% endif %}
Copy-Item "{{ winpe_temp_directory }}\{{ winpe_curl_directory }}\bin\*" -Destination "$mountDir\Windows\system32"

md "$mountDir\opt\bootstrap" -ea 0

Copy-Item "{{ winpe_temp_directory }}\init.cmd" -Destination "$mountDir\opt\bootstrap"
Copy-Item "{{ winpe_temp_directory }}\setsysname.cmd" -Destination "$mountDir\opt\bootstrap"

#Copy-Item C:\Windows\System32\timeout.exe -Destination "$mountDir\Windows\system32"

{% if winpe_load_drivers %}
md "$mountDir\drivers" -ea 0
# Load drivers
{% for driver in winpe_drivers %}
{% if driver.enable %}
Dism /Image:$mountDir /Add-Driver /Driver:"{{ winpe_temp_directory }}\{{ driver.name }}" /Recurse
Move-Item -Path "{{ winpe_temp_directory }}\{{ driver.name }}" -Destination "$mountDir\drivers"
{% endif %}
{% endfor %}
{% endif %}

{% if winpe_replace_wallpaper | bool %}
$imagePath = "$mountDir\Windows\system32\winpe.jpg"

# Change ownership to Administrators
Write-Host "Changing ownership to Administrators..."
icacls $imagePath /setowner "Administrators" /C

# Grant full control to Administrators
Write-Host "Granting full control to Administrators..."
icacls $imagePath /grant "Administrators:F" /C

# Replace the background image
Write-Host "Replacing the background image..."
Copy-Item "{{ winpe_temp_directory }}\winpe.jpg" -Destination $imagePath -Force

# Verify the change
if (Test-Path $imagePath) {
    Write-Host "Background image replaced successfully."
} else {
    Write-Host "Failed to replace the background image."
}
{% endif %}

# Optimize
Dism /Cleanup-Image /Image=$mountDir /StartComponentCleanup /ResetBase

Dism /Unmount-Image /MountDir:$mountDir /Commit

Dism /Export-Image /SourceImageFile:"c:\{{ winpe_name }}\media\sources\boot.wim" /SourceIndex:1 /DestinationImageFile:"$mountDir\boot2.wim"
Del "C:\{{ winpe_name }}\media\sources\boot.wim"
Move-Item "$mountDir\boot2.wim" "c:\{{ winpe_name }}\media\sources\boot.wim"