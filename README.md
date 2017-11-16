# windows-installation-recipes

## Next Version goals:
* Make this work with Windows Hyper-V kitchen VMs

## Version 0.1.1
This version has been minimally tested with windows on Azure for the following recipes:
* include_recipe 'windows-installation-recipes::windows-tweaks'
* include_recipe 'windows-installation-recipes::install-iis-serverinfo'
* include_recipe 'windows-installation-recipes::install-packages'

This is my library cookbook for Windows. It will combine code/resources from cookbooks/recipes such as:

* windows-rdp
* windows_tweaks
  * default (disable-servermanager, make PowerShell link)
  * windows-rdp (enable rdp for my HyperV image)
  * install-iis (includes server-info functionality)
* windows_ad (supermarket cookbook see xp-host-int-kit for example usage)

## Notes from Install_Packages for updating a library cookbook in GitHub
This is a kitchen sink and instructional cookbook/recipe. The intent is to load up every possible package I use, particularly Chocolatey packages. For on-the-fly builds, I can just create a dependency on this cookbook and build an attributes\default.rb where the packages to be installed are taken from the list below.

## Instructions for use in a local cookbook
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

## Recipe: install-iis-serverinfo

## Recipe: install-windows-packages (renamed to install-packages)
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

```