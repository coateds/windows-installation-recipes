# # encoding: utf-8

# Inspec test for recipe windows-installation-recipes::access-rdp

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

#### access-rdp ####
# Allow Access
describe registry_key ({
  hive: 'HKEY_LOCAL_MACHINE',
  key: 'SYSTEM\CurrentControlSet\Control\Terminal Server'
}) do
  its('fDenyTSConnections') { should eq 0 }
end

# NLA Only
describe registry_key ({
  hive: 'HKEY_LOCAL_MACHINE',
  key: 'SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp'
}) do
  its('UserAuthentication') { should eq 1 }
end

# Is the firewall rule enabled for all profiles?
fw_rule_enabled_script = <<-EOH
  $RDFwRuleEnabled = $true
  ForEach ($Item in Get-NetFirewallRule -DisplayGroup "Remote Desktop"){If ($Item.Enabled -eq "False") {$RDFwRuleEnabled = $false}}
  return $RDFwRuleEnabled
EOH

# The .chop is necessary to trim the carriage return/line feed from the output
describe powershell(fw_rule_enabled_script) do
  its('stdout.chop') { should eq 'True' }
end
#### /access-rdp ####
