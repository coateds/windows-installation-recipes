#
# Cookbook:: windows-installation-recipes
# Recipe:: windows-update-task
#
# Copyright:: 2018, The Authors, All Rights Reserved.

# Try running updates daily with the time set via attribute
windows_task 'windows-update' do
  command 'powershell get-windowsupdate -Install -AcceptAll -AutoReboot | out-file -append c:\scripts\WindowsUpdateLog.log'
  run_level :highest
  frequency :daily
  start_time "#{node['windows-update-task']['start-time']}"
end
