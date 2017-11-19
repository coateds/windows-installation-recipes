# Commands needed to set up Windows Update Module
# Install-PackageProvider -Name "NuGet" -Force
# Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
# Install-Module -name PSWindowsUpdate
# Add-WUServiceManager -ServiceID 7971f918-a847-4430-9279-4a52d1efe18d

# Command to run windows update
# Get-WUInstall –MicrosoftUpdate –AcceptAll –AutoReboot