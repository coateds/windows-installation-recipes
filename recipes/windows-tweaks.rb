#
# Cookbook:: windows-installation-recipes
# Recipe:: windows-tweaks
#
# Copyright:: 2017, The Authors, All Rights Reserved.

directory 'C:\scripts'

windows_task '\Microsoft\Windows\Server Manager\ServerManager' do
  action :disable
end

# Sometimes the PowerShell 5.1 installation wipes out the icons on the task bar
# This puts a link on the desktop as a short term fix
cookbook_file 'C:\Users\Public\Desktop\Windows PowerShell.lnk' do
  source 'Windows PowerShell.lnk'
end

powershell_script 'rename-computer' do
  code 'Rename-Computer -NewName hyperwindows'
  not_if '$env:COMPUTERNAME -eq "hyperwindows"'
end