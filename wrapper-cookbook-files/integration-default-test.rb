# # encoding: utf-8

# Inspec test for recipe hyperwindows::default

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

#### windows-tweaks ####
describe directory('C:\scripts') do
  it { should exist }
end

describe file('C:\Users\Public\Desktop\Windows PowerShell.lnk') do
  it { should exist }
end

describe windows_task('\Microsoft\Windows\Server Manager\ServerManager') do
  it { should be_disabled }
end

script = <<-EOH
  $env:COMPUTERNAME
EOH

# EDIT HERE!!
# Set the name (IN CAPS) for this test to match the new computername
# Comment it out if the computer is not to be renamed.
# For Azure, this should match the name set in .kitchen.yml (case sensitive)
describe powershell(script) do
  its('stdout.chop') { should eq 'HYPERWINDOWS' }
end
#### /windows-tweaks ####

#### install-packages ####
# Chocolatey should be installed and at the specified version
describe command('choco -v') do
  its('exit_status') { should eq 0 }
  its('stdout.chop') { should eq('0.10.8') }
end

# PowerShell should be at the specified version
describe command("$PSVersionTable.PSVersion.Major.ToString()+'.'+$PSVersionTable.PSVersion.Minor.ToString()") do
  its('exit_status') { should eq 0 }
  its('stdout.chop') { should eq '5.1' }
end

# PSWindowsUpdate should be installed
describe command('(Get-Module -ListAvailable -Name PSWindowsUpdate).Name') do
  its('exit_status') { should eq 0 }
  its('stdout.chop') { should eq 'PSWindowsUpdate' }
end

# PSWindowsUpdate should be Version 2
describe command('(Get-Module -ListAvailable -Name PSWindowsUpdate).version.major') do
  its('exit_status') { should eq 0 }
  its('stdout.chop') { should eq '2' }
end

## Install Apps

# Git
# Here the cli for Chocolatey is wrapped in PowerShell, in order to use the .substring command for just the first three chrs
describe command('(invoke-expression "choco list git --exact --local-only --limit-output").substring(0,3)') do
  its('exit_status') { should eq 0 }
  its('stdout.chop') { should eq 'git' }
end

# Here the cli for Chocolatey is wrapped in PowerShell, in order to use the .substring command for just the first sixteen chrs
describe command('(invoke-expression "choco list visualstudiocode --exact --local-only --limit-output").substring(0,16)') do
  its('exit_status') { should eq 0 }
  its('stdout.chop') { should eq 'visualstudiocode' }
end

describe command('(invoke-expression "choco list chefdk --exact --local-only --limit-output").substring(0,6)') do
  its('exit_status') { should eq 0 }
  its('stdout.chop') { should eq 'chefdk' }
end

describe command('(invoke-expression "choco list putty --exact --local-only --limit-output").substring(0,5)') do
  its('exit_status') { should eq 0 }
  its('stdout.chop') { should eq 'putty' }
end

describe command('(invoke-expression "choco list curl --exact --local-only --limit-output").substring(0,4)') do
  its('exit_status') { should eq 0 }
  its('stdout.chop') { should eq 'curl' }
end

describe command('(invoke-expression "choco list sysinternals --exact --local-only --limit-output").substring(0,12)') do
  its('exit_status') { should eq 0 }
  its('stdout.chop') { should eq 'sysinternals' }
end

describe command('(invoke-expression "choco list poshgit --exact --local-only --limit-output").substring(0,7)') do
  its('exit_status') { should eq 0 }
  its('stdout.chop') { should eq 'poshgit' }
end
#### install-packages ####

#### access-rdp ####
# Allow Access
describe registry_key(
  hive: 'HKEY_LOCAL_MACHINE',
  key: 'SYSTEM\CurrentControlSet\Control\Terminal Server'
) do
  its('fDenyTSConnections') { should eq 0 }
end

# NLA Only
describe registry_key(
  hive: 'HKEY_LOCAL_MACHINE',
  key: 'SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp'
) do
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

#### install-iis-serverinfo ####
describe port(80) do
  it { should be_listening }
end

describe command("(get-windowsfeature | Where-Object {$_.Name -eq 'Web-Server'}).InstallState") do
  its('stdout.chop') { should eq 'Installed' }
end

describe service('w3svc') do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end

# This test is not reliable
# describe command('(Invoke-WebRequest localhost).StatusCode') do
#   its('stdout.chop') { should eq '200' }
# end

# C:\scripts\default.htm or C:\inetpub\wwwroot\default.htm
describe file('C:\inetpub\wwwroot\default.htm') do
  it { should exist }
end
#### /install-iis-serverinfo ####

#### active-directory ####
domain_member_script = <<-EOH
(Get-WmiObject -Class Win32_ComputerSystem).Domain
EOH

describe powershell(domain_member_script) do
  its('stdout.chop') { should eq 'expcoatelab.com' }
end
#### /active-directory ####
