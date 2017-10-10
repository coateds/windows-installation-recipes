# windows-installation-recipes

This is my library cookbook for Windows. It will combine code/resources from cookbooks/recipes such as:

* windows-rdp
* install-windows-packages
* Install_Packages
* windows_tweaks
  * default (disable-servermanager, make PowerShell link)
  * windows-rdp (enable rdp for my HyperV image)
  * install-iis (includes server-info functionality)
* windows_ad (supermarket cookbook see xp-host-int-kit for example usage)

Notes on the Chocolatey cookbook
* https://supermarket.chef.io/cookbooks/chocolatey
* https://github.com/chocolatey/chocolatey-cookbook
* For integration testing, look https://github.com/chocolatey/chocolatey-cookbook/blob/master/test/integration/chef_latest/default_spec.rb
* At this time, I do not think there is a unit test for installing Chocolatey

Attributes
```
# NOTE: attributes are case sensitive!!
# set the following attributes to 'y' to install/upgrade
default['install-packages']['upgrade-chocolatey'] = 'n'

default['install-packages']['git']             = 'y'
default['install-packages']['vscode']          = 'y'
default['install-packages']['putty']           = 'n'
default['install-packages']['curl']            = 'n'
default['install-packages']['azstorexplorer']  = 'n'
default['install-packages']['chefdk']          = 'n'
default['install-packages']['sysinternals']    = 'n'
default['install-packages']['poshgit']         = 'n'
default['install-packages']['pester']          = 'n'
default['install-packages']['rdcman']          = 'n'
default['install-packages']['slack']           = 'n'

# packages that require a reboot, set the requestreboot attribute to 'y' as well
default['install-packages']['winazpowershell'] = 'y'
default['install-packages']['requestreboot']   = 'y'
```
