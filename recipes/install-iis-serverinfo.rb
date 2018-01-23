#
# Cookbook:: windows-installation-recipes
# Recipe:: install-iis-serverinfo
#
# Copyright:: 2017, The Authors, All Rights Reserved.

# There are a lot of changes and clean ups I want to do with this
# Two Sections
#  1. Installs and configures IIS
#  2. Gathers info, makes a webpage from template
# The template will create a page in a place according to an attribute
#   wwwroot or c:\scripts

#### Installs and configures IIS ####
if node['install-iis-serverinfo']['install-iis'].to_s == 'y'
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

  # put the serverinfo page at the root of the IIS web site
  node.override['install-iis-serverinfo']['infopage-path'] = 'c:/inetpub/wwwroot'
end
#### /Installs and configures IIS ####

#### Gathers info, makes a webpage from template ####
if node['install-iis-serverinfo']['create-infopage'].to_s == 'y'
  node.default['install-iis-serverinfo']['ps-network'] = ps_net
  node.default['install-iis-serverinfo']['ps-service'] = ps_service
  node.default['install-iis-serverinfo']['last-update'] = ps_lastupdate

  node.default['install-iis-serverinfo']['ntp-obj'] = JSON.parse(ps_ntp)
  # node['install-iis-serverinfo']['ntp-obj']['NTPTime']
  # node['install-iis-serverinfo']['ntp-obj']['SYSTime']
  # node['install-iis-serverinfo']['ntp-obj']['DIFFTime']

  # This attribute from PS Script takes the domain attribute as input
  node.default['install-iis-serverinfo']['ping-domain'] = ps_pingdomain node['domain'].to_s

  # Get a list of Chocolatey packages
  node.default['install-iis-serverinfo']['choco-list'] = ps_chocolist
  node.default['install-iis-serverinfo']['choco-outdated'] = ps_chocooutdated

  # Before using the template, it must be created
  # chef generate template default
  # Create the file templates\default.htm.erb
  # This tends to be case sensitive
  # Templates can use ohai automatic attributes for display
  #   This might be used to generate a kind of Chef generated BGInfo
  template "#{node['install-iis-serverinfo']['infopage-path']}/default.htm" do
    source 'default.htm.erb'
  end
end
#### /Gathers info, makes a webpage from template ####

# This will add borders to the PowerShell tables
node.override['install-iis-serverinfo']['ps-service'] = node['install-iis-serverinfo']['ps-service'].sub '<table>', '<table cellspacing=0 cellpadding=2 border=1>'
node.override['install-iis-serverinfo']['ps-network'] = node['install-iis-serverinfo']['ps-network'].sub '<table>', '<table cellspacing=0 cellpadding=2 border=1>'
node.override['install-iis-serverinfo']['choco-list'] = node['install-iis-serverinfo']['choco-list'].sub '<table>', '<table cellspacing=0 cellpadding=2 border=1>'
node.override['install-iis-serverinfo']['choco-outdated'] = node['install-iis-serverinfo']['choco-outdated'].sub '<table>', '<table cellspacing=0 cellpadding=2 border=1>'
