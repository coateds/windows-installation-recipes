#
# Cookbook:: windows-installation-recipes
# Recipe:: install-packages
#
# Copyright:: 2017, The Authors, All Rights Reserved.

# This will install Chocolatey if not already
include_recipe 'chocolatey::default'

# This will run an upgrade for images that include an old version
if node['install-packages']['upgrade-chocolatey'].to_s == 'y'
  chocolatey_package 'chocolatey' do
    action :upgrade
  end
end

if node['install-packages']['powershell51'].to_s == 'y'
  cookbook_file 'Win8.1AndW2K12R2-KB3191564-x64.msu' do
    source 'Win8.1AndW2K12R2-KB3191564-x64.msu'
  end

  # This resource is idempotent w/o the PS guard
  msu_package 'Win8.1AndW2K12R2-KB3191564-x64.msu' do
    source 'Win8.1AndW2K12R2-KB3191564-x64.msu'
    # action :remove
    action :install
    notifies :reboot_now, 'reboot[restart-computer]', :immediate
    # guard_interpreter :powershell_script
    # not_if '$PSVersionTable.PSVersion.Major -ge 5'
  end
end

# This resource block MUST occur after the post WMF 5.1 installation AND reboot
# Add-WUServiceManager -ServiceID 7971f918-a847-4430-9279-4a52d1efe18d
if node['install-packages']['PSWindowsUpdate'].to_s == 'y'
  powershell_script 'installpswindowsupdate' do
    code <<-EOH
    Install-PackageProvider -Name "NuGet" -Force
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
    Install-Module -name PSWindowsUpdate -Force
    EOH
    # Add -or [if PS -ne 5.1]
    # "$PSVersionTable.PSVersion.Major.ToString()+'.'+$PSVersionTable.PSVersion.Minor.ToString()"
    not_if "(Get-Module -ListAvailable -Name PSWindowsUpdate).Name -eq 'PSWindowsUpdate'"
  end
end

# chocolatey_package 'visualstudiocode'
# if node['install-packages']['vscode'].to_s == 'y'
#   chocolatey_package 'visualstudiocode'
# end
# Alternative (and favored by cookstyle) syntax for a simple conditional
chocolatey_package 'visualstudiocode' if node['install-packages']['vscode'].to_s == 'y'

# git will not be available to a logged on user (logout/logon to use it)
if node['install-packages']['git'].to_s == 'y'
  chocolatey_package 'git' do
    options '--params /GitAndUnixToolsOnPath'
  end
end

chocolatey_package 'chefdk' if node['install-packages']['chefdk'].to_s == 'y'
chocolatey_package 'putty' if node['install-packages']['putty'].to_s == 'y'
chocolatey_package 'sysinternals' if node['install-packages']['sysinternals'].to_s == 'y'
chocolatey_package 'curl' if node['install-packages']['curl'].to_s == 'y'
chocolatey_package 'poshgit' if node['install-packages']['poshgit'].to_s == 'y'
chocolatey_package 'pester' if node['install-packages']['pester'].to_s == 'y'
chocolatey_package 'rdcman' if node['install-packages']['rdcman'].to_s == 'y'
chocolatey_package 'slack' if node['install-packages']['slack'].to_s == 'y'
chocolatey_package 'azurestorageexplorer' if node['install-packages']['azstorexplorer'].to_s == 'y'

if node['install-packages']['winazpowershell'].to_s == 'y'
  chocolatey_package 'windowsazurepowershell' do
    action :install
    notifies :reboot_now, 'reboot[restart-computer]', :delayed
  end
end



if node['install-packages']['requestreboot'].to_s == 'y'
  reboot 'restart-computer' do
    action :request_reboot
    ignore_failure
  end
end

reboot 'restart-computer' do
  action :nothing
end

# notifies :reboot_now, 'reboot[Restart Computer]', :immediately

# cookbook_file 'c:\scripts\install-pswindowsupdate.ps1' do
#   source 'install-pswindowsupdate.ps1'
# end



# Command to run windows update
# Get-WUInstall –MicrosoftUpdate –AcceptAll –AutoReboot