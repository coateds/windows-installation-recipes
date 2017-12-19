# # encoding: utf-8

# Inspec test for recipe windows-installation-recipes::active-directory

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

#### active-directory ####
domain_member_script = <<-EOH
(Get-WmiObject -Class Win32_ComputerSystem).Domain
EOH

describe powershell(domain_member_script) do
  its('stdout.chop') { should eq 'expcoatelab.com' }
end
#### /active-directory ####
