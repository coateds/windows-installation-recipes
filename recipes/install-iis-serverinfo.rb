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
  
  #cmd = powershell_out('(get-hotfix | sort installedon | select -last 1).InstalledOn')
  #node.default['last_update'] = cmd.stdout.chop.to_s
  
  node.default['last_update'] = powershell_out('(get-hotfix | sort installedon | select -last 1).InstalledOn').stdout.chop.to_s
  
  # Before using the template, it must be created
  # chef generate template default
  # Create the file templates\default.htm.erb
  # This tends to be case sensitive
  # Templates can use ohai automatic attributes for display
  #   This might be used to generate a kind of Chef generated BGInfo
  template 'c:/inetpub/wwwroot/default.htm' do
    source 'default.htm.erb'
  end