#
# Cookbook:: windows-installation-recipes
# Recipe:: windows-tweaks
#
# Copyright:: 2017, The Authors, All Rights Reserved.

if node['windows-tweaks']['general-tweaks'].to_s == 'y'
  # I usually place scripts in the following directory, so why not create it right away
  directory 'C:\scripts'

  # This disables the scheduled task that opens Server Manager at everyone's logon
  windows_task '\Microsoft\Windows\Server Manager\ServerManager' do
    action :disable
  end

  # Sometimes the PowerShell 5.1 installation wipes out the icons on the task bar
  # This puts a link on the desktop as a short term fix
  # Remember that the cookbook_file resource copies a file from the cookbook to the client
  # It does not create it
  cookbook_file 'C:\Users\Public\Desktop\Windows PowerShell.lnk' do
    source 'Windows PowerShell.lnk'
  end
end

# Here I am going to start introducing PowerShell to the mix
# Use powershell out to get a single value from powershell into ruby for use later
# puts "Hostname:"
# puts powershell_out('$env:COMPUTERNAME').stdout.chop.to_s

# This is an example of a powershell_script resource. In this case the computer is being renamed
# However, the not_if guard_interpreter prevents the resource from running under certain circumstances
# Either:
# 1. The computer is already named as desired (the environment var matches the attribute)
#    This makes the resource idempotent
# 2. The attribute has a set value 'no-new-name' that allows the attribute to exist without causing a rename
# Note that the not_if guard also runs PowerShell, but with slightly different rules(?). Observe the extra escape characters ('\')
powershell_script 'rename-computer' do
  code "Rename-Computer -NewName #{node['windows-tweaks']['new-computername']}"
  notifies :reboot_now, 'reboot[restart-computer]', :delayed
  # notifies :reboot_now, 'reboot[restart-computer]', :immediate
  not_if "($env:COMPUTERNAME -eq \'#{node['windows-tweaks']['new-computername']}\') -or (\'#{node['windows-tweaks']['new-computername']}\' -eq 'no-new-name')"
end

# The resource block above uses the notifies option to initiate a reboot
# It can be either immediate or delayed (wait until the end of the chef run)
reboot 'restart-computer' do
  action :nothing
end
