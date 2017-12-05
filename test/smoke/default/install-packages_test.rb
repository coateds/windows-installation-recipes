# # encoding: utf-8

# Inspec test for recipe windows-installation-recipes::install-packages

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

# package installation section

# Testing for installed apps
# Test for PowerShell
# should match does a starts with compare
# use stdout.chop to do an exact match with eq
  describe command("$PSVersionTable.PSVersion.Major.ToString()+'.'+$PSVersionTable.PSVersion.Minor.ToString()") do
    its('exit_status') { should eq 0 }
    #its('stdout') { should match('5.1') }
    its('stdout.chop') { should eq '5.1' }
  end

# Test for a list of apps
# Each item will be treated as a single test
# %w(slack git putty curl).each do |item|
#   describe package(item) do
#     it { should be_installed }
#   end
# end

describe command('choco -v') do
  its('exit_status') { should eq 0 }
  its('stdout') { should match('0.10.8') }
end

# Most of the following describe blocks will run choco list...
# and capture/test its output
describe command('choco list AzureStorageExplorer --exact --local-only --limit-output') do
  its('exit_status') { should eq 0 }
  its('stdout') { should match('AzureStorageExplorer|') }
end

describe command('choco list chefdk --exact --local-only --limit-output') do
  its('exit_status') { should eq 0 }
  its('stdout') { should match('chefdk|') }
end

describe command('choco list git --exact --local-only --limit-output') do
  its('exit_status') { should eq 0 }
  its('stdout') { should match('git|') }
end

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


describe command('choco list sysinternals --exact --local-only --limit-output') do
  its('exit_status') { should eq 0 }
  its('stdout') { should match('sysinternals|') }
end

describe command('choco list poshgit --exact --local-only --limit-output') do
  its('exit_status') { should eq 0 }
  its('stdout') { should match('poshgit|') }
end

describe command('choco list pester --exact --local-only --limit-output') do
  its('exit_status') { should eq 0 }
  its('stdout') { should match('pester|') }
end

describe command('choco list rdcman --exact --local-only --limit-output') do
  its('exit_status') { should eq 0 }
  its('stdout') { should match('rdcman|') }
end

describe command('choco list visualstudiocode --exact --local-only --limit-output') do
  its('exit_status') { should eq 0 }
  its('stdout') { should match('visualstudiocode|') }
end

describe command('choco list putty --exact --local-only --limit-output') do
  its('exit_status') { should eq 0 }
  its('stdout') { should match('putty|') }
end

describe command('choco list curl --exact --local-only --limit-output') do
  its('exit_status') { should eq 0 }
  its('stdout') { should match('curl|') }
end

describe command('choco list windowsazurepowershell --exact --local-only --limit-output') do
  its('exit_status') { should eq 0 }
  its('stdout') { should match('windowsazurepowershell|') }
end

# This one package can be tested with the generic package test
describe package('slack') do
  it { should be_installed }
end

describe command('(Get-Module -ListAvailable -Name PSWindowsUpdate).Name') do
  its('exit_status') { should eq 0 }
  its('stdout.chop') { should eq 'PSWindowsUpdate' }
end

# /package installation section
