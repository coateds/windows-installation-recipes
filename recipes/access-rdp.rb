#
# Cookbook:: windows-installation-recipes
# Recipe:: access-rdp
#
# Copyright:: 2017, The Authors, All Rights Reserved.
# Set the Reg data var according to the Attribute

if node['my_windows_rdp']['ConfigureRDP'].to_s == 'y'

  case node['my_windows_rdp']['AllowConnections'].to_s
  when 'yes'
    allow = 0
  when 'no'
    allow = 1
  end

  # Change the registry if needed
  registry_key 'HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Control\\Terminal Server' do
    values [{
      name: 'fDenyTSConnections',
      type: :dword,
      data: allow,
    }]
    action :create
  end

  # Set the Reg data var according to the Attribute
  case node['my_windows_rdp']['AllowOnlyNLA'].to_s
  when 'yes'
    nla_only = 1
  when 'no'
    nla_only = 0
  end

  # Change the registry if needed
  registry_key 'HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Control\\Terminal Server\\WinStations\\RDP-Tcp' do
    values [{
      name: 'UserAuthentication',
      type: :dword,
      data: nla_only,
    }]
    action :create
  end

  # PowerShell script to determine if the firewall rule is enabled
  # Set a ruby variable to a string True/False
  fw_rule_enabled_script = <<-EOH
    $RDFwRuleEnabled = $true
    ForEach ($Item in Get-NetFirewallRule -DisplayGroup "Remote Desktop"){If ($Item.Enabled -eq "False") {$RDFwRuleEnabled = $false}}
    return $RDFwRuleEnabled
  EOH
  cmd = powershell_out(fw_rule_enabled_script)
  fw_rule_enabled = cmd.stdout.chop.to_s

  # This is the desired firewall rule action from attributes
  fw_should_be_enabled = node['my_windows_rdp']['ConfigureFirewall'].to_s

  # This uses Ruby code to decide what action to take and a powershell_script resouce to take action
  # No the most Chef-y way to do it, but much less confusing than my attempts to do it with guards
  if fw_rule_enabled == 'False' && fw_should_be_enabled == 'yes'
    puts 'FW rule should be enabled, and is not. Enable it'
    powershell_script 'Enable FW Rule' do
      code 'Enable-NetFirewallRule -DisplayGroup "Remote Desktop"'
    end
  elsif fw_rule_enabled == 'True' && fw_should_be_enabled == 'no'
    puts 'FW rule should NOT be enabled, and is. Disable it'
    powershell_script 'Enable FW Rule' do
      code 'Disable-NetFirewallRule -DisplayGroup "Remote Desktop"'
    end
  else
    puts 'No change to FW rule required'
  end

end
