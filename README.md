# windows-installation-recipes

## Next Version goals:
* Make this work with Windows Hyper-V kitchen VMs - (Mostly) Done

## Version 0.2.0
Recipes
* access-rdp
* active-directory
* install-iis-serverinfo
* install-packages
* powershell-demo
* windows-tweaks

## Version 0.1.1
This version has been minimally tested with windows on Azure for the following recipes:
* include_recipe 'windows-installation-recipes::windows-tweaks'
* include_recipe 'windows-installation-recipes::install-iis-serverinfo'
* include_recipe 'windows-installation-recipes::install-packages'

## Instructions for use in a local cookbook
* In metadata.rb
  * depends 'windows-installation-recipes'
* In Berksfile
  * cookbook "windows-installation-recipes", path: "C:/Users/dcoate/Documents/GitRepositories/windows-installation-recipes"
* In default recipe
```
# include_recipe 'windows-installation-recipes::windows-tweaks'
# include_recipe 'windows-installation-recipes::access-rdp'
# include_recipe 'windows-installation-recipes::install-packages'
# include_recipe 'windows-installation-recipes::active-directory'
# include_recipe 'windows-installation-recipes::install-iis-serverinfo'
# include_recipe 'windows-installation-recipes::powershell-demo'
```
uncomment as needed

## Instructions for use in a local cookbook (Old)
* In metadata.rb
  * depends 'Install_Packages', '>= 0.1.0'
* In Berksfile
  * cookbook "windows-installation-recipes", path: "C:/Users/user/Documents/GitRepositories/windows-installation-recipes"
  * cookbook "Install_Packages", "~> 0.1.0", git: "https://github.com/coateds/Install_Packages.git", ref: "42f15fcadbbdae33dae1daaa291b68bbaccbe9fb"
  * berks install (optional?)
* In the default recipe
  * include_recipe 'Install_Packages'
## Instructions for upgrading
* Make desired changes to this cookbook
  * Bump the version in metadata as needed
  * commit the changes in Git
  * push the changes to GitHub
  * use git log to get the revision number of the commit
* Make changes to cookbooks that will consume this cookbook
  * Update the Berksfile with cookbook version and ref
  * berks update Install_Packages

Notes on the Chocolatey cookbook
* https://supermarket.chef.io/cookbooks/chocolatey
* https://github.com/chocolatey/chocolatey-cookbook
* For integration testing, look https://github.com/chocolatey/chocolatey-cookbook/blob/master/test/integration/chef_latest/default_spec.rb
* At this time, I do not think there is a unit test for installing Chocolatey

## Recipe: windows-tweaks
* C:\scripts
* Disable Server Manager Sched Task start at logon
* PowerShell Shortcut on Desktop
* Rename Computer

Attributes:
```
#### windows-tweaks ####
# Leave this at no-new-name to do nothing
# Or set this to have a new name
# default['windows-tweaks']['new-computername']  = 'no-new-name'
default['windows-tweaks']['new-computername']  = '[new computer name]'
#### /windows-tweaks ####
```

ChefSpec Unit Tests
```diff
    #### windows-tweaks ####

    # These tests tend to be case sensitive between test and resource
    # ('c:\scripts' will not work)
    it 'creates the directory c:\scripts' do
      expect(chef_run).to create_directory('C:\scripts')
    end

    it 'disables the task \Microsoft\Windows\Server Manager\ServerManager' do
      expect(chef_run).to disable_windows_task('\Microsoft\Windows\Server Manager\ServerManager')
    end

    it 'creates the cookbook file PowerShell/lnk' do
      expect(chef_run).to create_cookbook_file('C:\Users\Public\Desktop\Windows PowerShell.lnk')
    end
    #### /windows-tweaks ####

-Cannot handle the PowerShell script resource at all
-Unless the guard on the powershell_resource is commented out, all tests will fail!
```

InSpec Integration Tests
```#### windows-tweaks ####
describe directory('C:\scripts') do
  it { should exist }
end

describe file('C:\Users\Public\Desktop\Windows PowerShell.lnk') do
  it { should exist }
end

describe windows_task ('\Microsoft\Windows\Server Manager\ServerManager') do
  it { should be_disabled }
end

script = <<-EOH
  $env:COMPUTERNAME
EOH

# not completely happy with the match vs eq
# The output of the script is "SERVERX5\r\n"
# I tried the appeand .replace("\r\n", "") and it did not work
# might keep trying variants later
describe powershell(script) do
  its('stdout.chop') { should eq '[EXPECTED NAME IN CAPS]' }
end
#### /windows-tweaks ####
```

## Recipe: install-windows-packages (renamed to install-packages)
This is a big recipe as I am storing a lot of information/instruction within
* The first thing this recipe does is install Chocolatey using the supermarket Chocolatey resource. There is also a resource block to upgrade Chocolatey if specified in attributes.
* Next it will upgrade PowerShell (to 5.1) if needed


Attributes: (under construction)
```
#### install-packages ####
default['install-packages']['upgrade-chocolatey'] = 'y'

# PowerShell and modules
# More work and testing is likely needed to handle all (likely) scenarios
# Regarding what is installed and what needs to be upgraded
default['install-packages']['powershell51']       = 'y'
default['install-packages']['PSWindowsUpdate']    = 'y'

default['install-packages']['git']             = 'y'

default['install-packages']['vscode']          = 'n'
default['install-packages']['putty']           = 'n'
default['install-packages']['curl']            = 'n'
default['install-packages']['azstorexplorer']  = 'n'
default['install-packages']['chefdk']          = 'n'
default['install-packages']['sysinternals']    = 'n'
default['install-packages']['poshgit']         = 'n'
default['install-packages']['pester']          = 'n'
default['install-packages']['rdcman']          = 'n'
default['install-packages']['slack']           = 'n'
#### install-packages ####
```

Earlier Documentation

This is designed to be a true, attribute driven, library recipe to be called from a wrapper cookbook. It contains a series of resource blocks that install specific software packages with options and customizations. At a minimum, the examples here can be copied to other cookbooks and as such this can be treated as a documentation point. This documentation will extend to ChefSpec and InSpec tests in install-packages_spec.rb and install-packages_test.rb files.

Most of work here is done with the `chocolatey_package` resource. However, this resource cannot install MSU packages. (This cannot be done over PS Remote) The recipe contains an example for installing PS5.1 using the `msu_package`.

Both the PS5.1 and one of the Chocolatey packages require a reboot. Another potential recipe/resource requiring a reboot is joining a domain. As of this writing, I am explicitly placing a reboot resource in the needed place. However, a reboot block is often called from a 'notifies' option. Below is some minimally tested code:

```
# recipe that works
chocolatey_package 'windowsazurepowershell' do
  action :install
  ignore_failure
  notifies :reboot_now, 'reboot[restart-computer]', :delayed
end

reboot 'restart-computer' do
  action :nothing
end

# chefspec that works
    it 'installs a package' do
      expect(chef_run).to install_chocolatey_package('windowsazurepowershell')
    end

    it 'reboots after install' do
      resource = chef_run.chocolatey_package('windowsazurepowershell')
      expect(resource).to notify('reboot[restart-computer]').to(:reboot_now).delayed
    end
```

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

## Recipe: install-iis-serverinfo

### An example to consider:
```
#### recipe ####
include_recipe 'chocolatey'

chocolatey_package 'sysinternals'

chocolatey_package 'powershell' do
  action :install
  version node['ipc_windows']['powershell']['version']
  returns [0, 3010]
  guard_interpreter :powershell_script
  not_if '$PSVersionTable.PSVersion.Major -ge 5'
  notifies :reboot_now, 'reboot[powershell package installation requires reboot]', :immediately
end

reboot 'powershell package installation requires reboot' do
  action :nothing
  # required to have 1 minute minimum to avoid test kitchen error exception
  delay_mins node['ipc_windows']['powershell']['reboot_delay']
end
#### /recipe ####

#### ChefSpec test ####
require 'spec_helper'

describe 'ipc_windows::chocolatey' do
  context 'When all attributes are default, on Windows Server 2012 R2 and WMF5 is not installed' do
    before do
      stub_command('$PSVersionTable.PSVersion.Major -ge 5').and_return(false)
    end

    let(:chef_run) do
      # for a complete list of available platforms and versions see:
      # https://github.com/customink/fauxhai/blob/master/PLATFORMS.md
      runner = ChefSpec::SoloRunner.new(platform: 'windows', version: '2012R2')
      runner.converge(described_recipe)
    end

    it 'install chocolatey' do
      expect(chef_run).to include_recipe('chocolatey')
    end

    it 'install sysinternals chocolatey package' do
      expect(chef_run).to install_chocolatey_package('sysinternals')
    end

    it 'install powershell chocolatey package' do
      expect(chef_run).to install_chocolatey_package('powershell')
    end

    it 'reboots computer' do
      powershell = chef_run.chocolatey_package('powershell')
      expect(powershell).to notify('reboot[powershell package installation requires reboot]').to(:reboot_now).immediately
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end
  end

  context 'When all attributes are default, on Windows Server 2012 R2 and WMF5 is installed' do
    before do
      stub_command('$PSVersionTable.PSVersion.Major -ge 5').and_return(true)
    end

    let(:chef_run) do
      # for a complete list of available platforms and versions see:
      # https://github.com/customink/fauxhai/blob/master/PLATFORMS.md
      runner = ChefSpec::SoloRunner.new(platform: 'windows', version: '2012R2')
      runner.converge(described_recipe)
    end

    it 'install chocolatey' do
      expect(chef_run).to include_recipe('chocolatey')
    end

    it 'install sysinternals chocolatey package' do
      expect(chef_run).to install_chocolatey_package('sysinternals')
    end

    it 'does not install powershell chocolatey package' do
      expect(chef_run).to_not install_chocolatey_package('powershell')
    end

    it 'does not reboot' do
      expect(chef_run).to_not request_reboot('powershell package installation requires reboot')
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end
  end
end
#### /ChefSpec test ####
```

## Recipe: access-rdp

Attributes
```
default['my_windows_rdp']['AllowConnections']  = 'yes/no'
default['my_windows_rdp']['AllowOnlyNLA']      = 'yes/no'
default['my_windows_rdp']['ConfigureFirewall'] = 'yes/no'
```