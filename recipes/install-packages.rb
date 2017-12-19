#
# Cookbook:: windows-installation-recipes
# Recipe:: install-packages
#
# Copyright:: 2017, The Authors, All Rights Reserved.

# A Function to return the PowerShell Version using PowerShell
# def ps_ver
#   ps_psver_script = <<-EOH
#   $PSVersionTable.PSVersion.Major.ToString()+'.'+$PSVersionTable.PSVersion.Minor.ToString()
#   EOH
#   powershell_out(ps_psver_script).stdout.chop.to_s
# end

# ps_version = "#{ps_ver}"
ps_version = ps_ver.to_s

# Chef::Resource::User.send(:include, WindowsInstallationRecipes::HelperHelpers)

# This will install Chocolatey if not already
include_recipe 'chocolatey::default' if node['install-packages']['basic-chocolatey'].to_s == 'y'

# This will run an upgrade for images that include an old version
if node['install-packages']['upgrade-chocolatey'].to_s == 'y'
  chocolatey_package 'chocolatey' do
    action :upgrade
  end
end

# Do not copy or install PS 5.1 if it is already there (such as on 2016)
if node['install-packages']['powershell51'].to_s == 'y'
  # The msu file be copied explicitly before
  cookbook_file 'Win8.1AndW2K12R2-KB3191564-x64.msu' do
    source 'Win8.1AndW2K12R2-KB3191564-x64.msu'
    # guard_interpreter :powershell_script
    # not_if "$PSVersionTable.PSVersion.Major.ToString()+'.'+$PSVersionTable.PSVersion.Minor.ToString() -eq '5.1'"
    not_if { ps_version == '5.1' }
    # not_if { ps_ver.to_s == '5.1' }
  end

  # This resource is idempotent w/o the PS guard
  # but runs under 2016 when it not necessary
  msu_package 'Win8.1AndW2K12R2-KB3191564-x64.msu' do
    source 'Win8.1AndW2K12R2-KB3191564-x64.msu'
    # action :remove
    action :install
    notifies :reboot_now, 'reboot[restart-computer]', :immediate
    # guard_interpreter :powershell_script
    # not_if "$PSVersionTable.PSVersion.Major.ToString()+'.'+$PSVersionTable.PSVersion.Minor.ToString() -eq '5.1'"
    not_if { ps_version == '5.1' }
  end
end

# This resource block MUST occur after the post WMF 5.1 installation AND reboot
# Add-WUServiceManager -ServiceID 7971f918-a847-4430-9279-4a52d1efe18d
# if node['install-packages']['PSWindowsUpdate'].to_s == 'y'
#   powershell_script 'installpswindowsupdate' do
#     code <<-EOH
#     Install-PackageProvider -Name "NuGet" -Force
#     Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
#     Install-Module -name PSWindowsUpdate -Force
#     EOH
#     # Add -or [if PS -ne 5.1]
#     # "$PSVersionTable.PSVersion.Major.ToString()+'.'+$PSVersionTable.PSVersion.Minor.ToString()"
#     # not_if "(Get-Module -ListAvailable -Name PSWindowsUpdate).Name -eq 'PSWindowsUpdate'"
#
#     # New guard:   (Still testing)
#     not_if "((Get-Module -ListAvailable -Name PSWindowsUpdate).Name -eq 'PSWindowsUpdate') -or ($PSVersionTable.PSVersion.Major.ToString()+'.'+$PSVersionTable.PSVersion.Minor.ToString() -ne '5.1')"
#   end
# end

# Running Update-Module just adds the new version along side the current
# This messes up existing tests
# For now, uninstall old first then install the new
if node['install-packages']['PSWindowsUpdate'].to_s == 'y'
  powershell_script 'Uninstall PSWindowsUpdate' do
    code 'Uninstall-Module -Name PSWindowsUpdate'
    not_if '(Get-Module -ListAvailable -Name PSWindowsUpdate).version.major -eq 2'
  end

  powershell_package 'PSWindowsUpdate'
  # powershell_script 'update-pswindowsupdate' do
  #   code <<-EOH
  #   Uninstall-Module -Name PSWindowsUpdate
  #   Install-Module -Name PSWindowsUpdate
  #   # Update-Module -Name PSWindowsUpdate -Confirm
  #   EOH
  #   not_if "(Get-Module -ListAvailable -Name PSWindowsUpdate).version.major -eq 2"
  # end
end

########################
# This is the end of the PowerShell and module install/upgrade section
# It still needs to be fully tested and possibly re-factored
########################

# git will not be available to a logged on user (logout/logon to use it)
if node['install-packages']['git'].to_s == 'y'
  chocolatey_package 'git' do
    options '--params /GitAndUnixToolsOnPath'
    # action :uninstall
  end
end

# Chocolatey attempts to install DotNet4.5.2 with VSCode
# currently (Dec 2017) This fails on 2012R2
# This does work for 2016
# attempting to explicitly call this install ahead of VSCode
# howwever, the DotNet install calls for a reboot
if node['install-packages']['vscode'].to_s == 'y'
  # chocolatey_package 'dotnet4.5.2'
  chocolatey_package 'visualstudiocode' do
    action :install
    only_if { node[:platform_version] == '10.0.14393' }
  end
end

if node['install-packages']['chefdk'].to_s == 'y'
  chocolatey_package 'chefdk' do
    action :install
    ignore_failure true
  end
end

# Alternative (and favored by cookstyle) syntax for a simple conditional
# Use this syntax when there are no options and the default action is used
# chocolatey_package 'chefdk' if node['install-packages']['chefdk'].to_s == 'y'
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

if node['install-packages']['install-updates'].to_s == 'y'
  powershell_script 'Install Updates' do
    code 'Get-WindowsUpdate -Install -AcceptAll -AutoReboot'
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

# Command to run windows update
# Get-WUInstall –MicrosoftUpdate –AcceptAll –AutoReboot
