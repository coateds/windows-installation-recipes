#
# Cookbook:: windows-installation-recipes
# Recipe:: active-directory
#
# Copyright:: 2017, The Authors, All Rights Reserved.

# Join coatelab.com domain
# The resource name in the first line does not seem to matter
windows_ad_computer 'This_Computer' do
  action :unjoin
  domain_pass 'H0rnyBunny'
  domain_user 'Administrator'
  domain_name 'expcoatelab.com'
  # domain_name node['active-directory']['domain-name']
  restart true
end
