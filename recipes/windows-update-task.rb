#
# Cookbook:: windows-installation-recipes
# Recipe:: windows-update-task
#
# Copyright:: 2018, The Authors, All Rights Reserved.

# Try running updates on select machines every 30 min
windows_task 'windows-update' do
  command 'powershell get-windowsupdate -Install -AcceptAll -AutoReboot | out-file -append c:\scripts\WindowsUpdateLog.log'
  run_level :highest
  frequency :minute
  frequency_modifier 30
  # start_time '09:22'
end
