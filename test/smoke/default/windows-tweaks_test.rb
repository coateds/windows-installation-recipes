# # encoding: utf-8

# Inspec test for recipe windows-installation-recipes::windows-tweaks

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

computernamescript = <<-EOH
  $env:COMPUTERNAME
EOH

# not completely happy with the match vs eq
# The output of the script is "SERVERX5\r\n"
# I tried the appeand .replace("\r\n", "") and it did not work
# might keep trying variants later
describe powershell(computernamescript) do
  its('stdout.chop') { should eq '[EXPECTED NAME IN CAPS]' }
end
#### /windows-tweaks ####
