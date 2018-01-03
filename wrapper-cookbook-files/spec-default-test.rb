#
# Cookbook:: hyperwindows2016_1
# Spec:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

require 'spec_helper'

describe 'hyperwindows2016_1::default' do
  context 'When all attributes are default, on a Windows 2016' do
    let(:chef_run) do
      # for a complete list of available platforms and versions see:
      # https://github.com/customink/fauxhai/blob/master/PLATFORMS.md
      # runner = ChefSpec::ServerRunner.new(platform: 'windows', version: '2016')
      runner = ChefSpec::ServerRunner.new(platform: 'windows', version: '2016') do |node|
        node.override['psversion'] = '4.0'
      end
      runner.converge(described_recipe)
    end

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

    #### install-packages ####
    it 'includes the chocolatey recipe' do
      expect(chef_run).to include_recipe('chocolatey::default')
    end

        ### Use these together ###
    # These two blocks will test with the expectation of an explicit reboot
    it 'creates the file Win8.1AndW2K12R2-KB3191564-x64.msu in cache' do
      expect(chef_run).to create_cookbook_file('Win8.1AndW2K12R2-KB3191564-x64.msu')
    end

    it 'installs a msu_package Win8.1AndW2K12R2-KB3191564-x64.msu' do
      expect(chef_run).to install_msu_package('Win8.1AndW2K12R2-KB3191564-x64.msu')
    end

    # Add this block if the reboot should be called via notifies
    it 'reboots after install' do
      resourceps = chef_run.msu_package('Win8.1AndW2K12R2-KB3191564-x64.msu')
      expect(resourceps).to notify('reboot[restart-computer]').to(:reboot_now).immediately
    end

    it 'installs powershell Windows update package' do
      expect(chef_run).to install_powershell_package('PSWindowsUpdate')
    end

    it 'installs a package' do
      expect(chef_run).to install_chocolatey_package('git').with(
      options: '--params /GitAndUnixToolsOnPath')
    end

    it 'installs VS Code' do
      expect(chef_run).to install_chocolatey_package('visualstudiocode')
    end
    #### /install-packages ####

    #### access-rdp ####
    it 'modifies a registry_key' do
      expect(chef_run).to create_registry_key('HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Control\\Terminal Server').with(
        unscrubbed_values: [
          {
            name: 'fDenyTSConnections',
            type: :dword,
            data: 0,
          }
        ]
      )
    end

    it 'modifies a registry_key' do
      expect(chef_run).to create_registry_key('HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Control\\Terminal Server\\WinStations\\RDP-Tcp').with(
        unscrubbed_values: [
          {
            name: 'UserAuthentication',
            type: :dword,
            data: 1,
          }
        ]
      )
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end
  end
end
