#
# Cookbook:: windows-installation-recipes
# Recipe:: windows-update-task
#
# Copyright:: 2018, The Authors, All Rights Reserved.

# Try running updates daily with the time set via attribute
# The force property will cause the task to be overwritten
windows_task 'windows-update' do
  command 'powershell get-date | out-file -append c:\scripts\WindowsUpdateLog.log; get-windowsupdate -Install -AcceptAll -AutoReboot | out-file -append c:\scripts\WindowsUpdateLog.log'
  run_level :highest
  frequency :daily
  start_time "#{node['windows-update-task']['start-time']}"
  force
end
