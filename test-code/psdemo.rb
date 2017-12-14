# A Function to return the PowerShell Version using PowerShell
#def ps_ver
#    ps_psver_script = <<-EOH
#    $PSVersion = $PSVersionTable.PSVersion.Major.ToString()+'.'+$PSVersionTable.PSVersion.Minor.ToString()
#    $PSVersion
#    # If ($PSVersion -eq 5.1) {$True}
#    # Else {$False}
#    EOH
#    powershell_out(ps_psver_script).stdout.chop.to_s
#end


# def ps_ver
#     ps_psver_script = <<-EOH
#     $PSVersion = $PSVersionTable.PSVersion.Major.ToString()+'.'+$PSVersionTable.PSVersion.Minor.ToString()
#     EOH
#     puts powershell_out(ps_psver_script).stdout
#     if powershell_out(ps_psver_script).stdout.chop.to_s == 5.1
#         return true
#     else
#         return false, powershell_out(ps_psver_script).stdout.chop.to_s
#     end
# end

# def ps_ver
#     ps_psver_script = <<-EOH
#     $PSVersionTable.PSVersion.Major.ToString()+'.'+$PSVersionTable.PSVersion.Minor.ToString()
#     EOH
#     powershell_out(ps_psver_script).stdout.chop.to_s
# end
#
# ps_version = ps_ver.to_s
#
# ruby_block 'PS Ver Test' do
#     block do
#         puts "Yes, it is version 5.1"
#     end
#     only_if { ps_version == '5.1' }
# end

# def ps_fn var
#   puts var
#   ps_fn_script = <<-EOH
#   "#{var}" + "licious"
#   EOH
#   powershell_out(ps_fn_script).stdout.chop.to_s
# end
#
# puts ps_fn "Booger"

# Get-WmiObject win32_networkadapter -filter "netconnectionstatus = 2" | select netconnectionid, name, InterfaceIndex, netconnectionstatus

# ps_fn_script = <<-EOH
# "Loco-Mode!!"
# Get-WmiObject win32_networkadapter -filter "netconnectionstatus = 2" | select netconnectionid, name, InterfaceIndex, netconnectionstatus
# EOH
# puts powershell_out(ps_fn_script).stdout.chop.to_s

ps_net_script = <<-EOH
Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter IPEnabled=TRUE -ComputerName . | Format-Table -Property Description, IPAddress, DHCPEnabled
EOH

ps_ntp_script = <<-EOH
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
$NTPTime = ([datetime]'1/1/1900' ).AddSeconds( $Seconds ).ToLocalTime()
$SysTime = Get-Date
$DiffTime = [math]::abs(($NTPTime - $SysTime).TotalSeconds)

$obj = New-Object -TypeName PSObject
Add-Member -InputObject $obj -MemberType NoteProperty -Name NTPTime -Value $NTPTime.ToString()
Add-Member -InputObject $obj -MemberType NoteProperty -Name SYSTime -Value $SysTime.ToString()
Add-Member -InputObject $obj -MemberType NoteProperty -Name DIFFTime -Value $DiffTime

return $obj | ConvertTo-Json
EOH

ps_service_script = <<-EOH
Get-Service | Where-Object {($_.status -ne 'running') -and ($_.StartType -eq 'Automatic')} | Select-Object Status, Name, DisplayName, StartType
EOH

puts
puts
puts "Ohai Information For"
puts "Hostname: #{node['hostname']}, (#{node['fqdn']})"
puts "Domain: #{node['domain']}"
puts "Platform: #{node['platform']}, (v #{node['platform_version']})"
# Not relevant in Windows  puts "Platform Family: #{node['platform_family']}"

puts
puts "Chef Information"
puts "Recipes: #{node['recipes']}"
puts "Roles: #{node['roles']}"

puts
puts "Addresses: #{node['ipaddress']}, #{node['macaddress']}"
# Container:   puts "cpu: #{node['cpu']}"
puts "cpu: #{node['cpu']['0']['model_name']}"
puts "real:#{node['cpu']['real']}  cores:#{node['cpu']['cores']}  total:#{node['cpu']['total']}"
puts "memory: #{node['memory']['total']}"
puts "c: % used: #{node['filesystem']['C:']['percent_used']}"

puts
puts "Network"
puts powershell_out(ps_net_script).stdout.chop.to_s

puts
puts "virtualizationinfo: #{node['VirtualizationInfo']}"

# PowerShell converts a custom object to JSON format
# Ruby is then able to convert this to a hash
dt = powershell_out(ps_ntp_script)
node.default['obj'] = JSON.parse(dt.stdout)
puts
puts "Time Diff"
puts "NTPTime: #{node['obj']['NTPTime']}  SYSTime: #{node['obj']['SYSTime']}  DIFFTime: #{node['obj']['DIFFTime']}"

puts
puts "Stopped Services set to Auto"
puts powershell_out(ps_service_script).stdout.chop.to_s