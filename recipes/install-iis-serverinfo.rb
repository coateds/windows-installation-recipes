#
# Cookbook:: windows-installation-recipes
# Recipe:: install-iis-serverinfo
#
# Copyright:: 2017, The Authors, All Rights Reserved.
# Installs the Web Server Feature/Role
# powershell_script 'Install IIS' do
#   code 'Add-WindowsFeature Web-Server'
#   guard_interpreter :powershell_script
#   not_if '(Get-WindowsFeature -Name Web-Server).Installed'
# end

# This is another way to install a feature/role. It is in the Windows cookbook
# There are three ways it can install dism, svrmgrcli and powershell
# if not specified, it will choose it's preferred method
# Docs here: https://github.com/chef-cookbooks/windows
windows_feature 'IIS-WebServerRole' do
  action :install
  install_method :windows_feature_dism
end
# Look in https://github.com/chef-cookbooks/windows/blob/master/libraries/matchers.rb
# for ChefSpec unit test syntax

# This is generally not necessary after install, but useful to prevent configuration drift.
service 'w3svc' do
  action [:enable, :start]
end

node.default['recipe_var'] = 'Gooberlicious'

# cmd = powershell_out('(get-hotfix | sort installedon | select -last 1).InstalledOn')
# node.default['last_update'] = cmd.stdout.chop.to_s

# cookbook_file 'C:\scripts\ntp-time.ps1' do
#   source 'ntp-time.ps1'
# end

get_ntp_script = <<-EOH
$NTPServer = '129.6.15.28'
# Build NTP request packet. We'll reuse this variable for the response packet
$NTPData    = New-Object byte[] 48  # Array of 48 bytes set to zero
$NTPData[0] = 27                    # Request header: 00 = No Leap Warning; 011 = Version 3; 011 = Client Mode; 00011011 = 27

# Open a connection to the NTP service
$Socket = New-Object Net.Sockets.Socket ( 'InterNetwork', 'Dgram', 'Udp' )
$Socket.SendTimeOut    = 2000  # ms
$Socket.ReceiveTimeOut = 2000  # ms
$Socket.Connect( $NTPServer, 123 )

# Make the request
$Null = $Socket.Send(    $NTPData )
$Null = $Socket.Receive( $NTPData )

# Clean up the connection
$Socket.Shutdown( 'Both' )
$Socket.Close()

# Extract relevant portion of first date in result (Number of seconds since "Start of Epoch")
$Seconds = [BitConverter]::ToUInt32( $NTPData[43..40], 0 )

# Add them to the "Start of Epoch", convert to local time zone, and return
return ( [datetime]'1/1/1900' ).AddSeconds( $Seconds ).ToLocalTime()
EOH
cmd = powershell_out(get_ntp_script)
# fw_rule_enabled = cmd.stdout.chop.to_s
# puts fw_rule_enabled


node.default['last_update'] = powershell_out('(get-hotfix | sort installedon | select -last 1).InstalledOn').stdout.chop.to_s
node.default['system_time'] = powershell_out('get-date').stdout.chop.to_s
node.default['ntp_time'] = cmd.stdout.chop.to_s
#node.default['is_correct_time'] = powershell_out('((Invoke-WebRequest -Uri \'time.is\').rawcontent).contains(\'Your time is exact\')').stdout
# .contains('Your time is exact')

# Before using the template, it must be created
# chef generate template default
# Create the file templates\default.htm.erb
# This tends to be case sensitive
# Templates can use ohai automatic attributes for display
#   This might be used to generate a kind of Chef generated BGInfo
template 'c:/inetpub/wwwroot/default.htm' do
  source 'default.htm.erb'
end
