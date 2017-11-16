# # encoding: utf-8

# Inspec test for recipe windows-installation-recipes::install-iis-serverinfo

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

#### install-iis-serverinfo ####
describe port(80) do
  it { should be_listening }
end

describe windows_feature('IIS-WebServerRole') do
  it { should be_installed }
end

describe service('w3svc') do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end

describe command('(Invoke-WebRequest localhost).StatusCode') do
  its('stdout') { should match '200' }
end
#### /install-iis-serverinfo ####
