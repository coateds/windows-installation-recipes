# This Ruby block will only run if Windows 2016
ruby_block '2016 Test' do
  block do
    puts "This indicates a guard that runs only if Windows 2016"
  end
  action :run
  only_if { node[:platform_version]  == '10.0.14393' }
end
  
include_recipe 'windows-installation-recipes::windows-tweaks'
include_recipe 'windows-installation-recipes::install-packages'
include_recipe 'windows-installation-recipes::access-rdp'
include_recipe 'windows-installation-recipes::install-iis-serverinfo'

# include_recipe 'windows-installation-recipes::active-directory'
# include_recipe 'windows-installation-recipes::powershell-demo'
  