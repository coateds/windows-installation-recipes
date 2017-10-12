#
# Cookbook:: windows-installation-recipes
# Recipe:: install-packages
#
# Copyright:: 2017, The Authors, All Rights Reserved.

include_recipe 'chocolatey::default'

# This will run an upgrade for images that include an old version
if node['install-packages']['upgrade-chocolatey'].to_s == 'y'
  chocolatey_package 'chocolatey' do
    action :upgrade
  end
end

#chocolatey_package 'visualstudiocode'
if node['install-packages']['vscode'].to_s == 'y'
  chocolatey_package 'visualstudiocode'
end

# git will not be available to a logged on user (logout/logon to use it)
if node['install-packages']['git'].to_s == 'y'
  chocolatey_package 'git' do
     options '--params /GitAndUnixToolsOnPath'
  end
end

if node['install-packages']['chefdk'].to_s == 'y'
  chocolatey_package 'chefdk'
end

if node['install-packages']['putty'].to_s == 'y'
  chocolatey_package 'putty'
end
if node['install-packages']['sysinternals'].to_s == 'y'
  chocolatey_package 'sysinternals'
end

if node['install-packages']['curl'].to_s == 'y'
  chocolatey_package 'curl'
end

# Non functional??  Seems to work now??
if node['install-packages']['poshgit'].to_s == 'y'
  chocolatey_package 'poshgit'
end

if node['install-packages']['pester'].to_s == 'y'
  chocolatey_package 'pester'
end

if node['install-packages']['rdcman'].to_s == 'y'
  chocolatey_package 'rdcman'
end

if node['install-packages']['slack'].to_s == 'y'
  chocolatey_package 'slack'
end

if node['install-packages']['azstorexplorer'].to_s == 'y'
  chocolatey_package 'azurestorageexplorer'
end

if node['install-packages']['winazpowershell'].to_s == 'y'
  chocolatey_package 'windowsazurepowershell' do
    action :install
    notifies :reboot_now, 'reboot[restart-computer]', :delayed
  end
end

if node['install-packages']['powershell51'].to_s == 'y'
  cookbook_file 'Win8.1AndW2K12R2-KB3191564-x64.msu' do
  	source 'Win8.1AndW2K12R2-KB3191564-x64.msu'
  end

  msu_package 'Win8.1AndW2K12R2-KB3191564-x64.msu' do
    source 'Win8.1AndW2K12R2-KB3191564-x64.msu'
    # action :remove
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