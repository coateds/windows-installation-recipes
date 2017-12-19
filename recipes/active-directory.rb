#
# Cookbook:: windows-installation-recipes
# Recipe:: active-directory
#
# Copyright:: 2017, The Authors, All Rights Reserved.

# Join coatelab.com domain
# The resource name in the first line does not seem to matter
windows_ad_computer node['windows-tweaks']['new-computername'] do
  action node['active-directory']['action']
  domain_pass node['active-directory']['domain_pass']
  domain_user node['active-directory']['domain_user']
  domain_name node['active-directory']['domain_name']
  restart true
end


# windows_ad_computer 'HYPERWINDOWS16' do
#   action :unjoin
#   domain_pass 'H0rnyBunny'
#   domain_user 'Administrator'
#   domain_name 'expcoatelab.com'
#   # domain_name node['active-directory']['domain-name']
#   restart true
# end
