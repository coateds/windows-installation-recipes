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

# Rename the computer is not equal to 'no-new-name'
# if node['windows-tweaks']['new-computername'].to_s != 'no-new-name'
#   puts node['windows-tweaks']['new-computername']
#   powershell_script 'rename-computer' do
#     code "Rename-Computer -NewName #{node['windows-tweaks']['new-computername']}"
#     not_if "env:COMPUTERNAME -eq #{node['windows-tweaks']['new-computername']}"
#   end
# end

# Still working on the logic and syntax here
# powershell_script 'rename-computer' do
#   code "Rename-Computer -NewName #{node['windows-tweaks']['new-computername']}"
#   not_if "(env:COMPUTERNAME -eq #{node['windows-tweaks']['new-computername']} OR #{node['windows-tweaks']['new-computername']} -ne 'no-new-name'"
# end
