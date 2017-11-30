#
# Cookbook:: windows-installation-recipes
# Spec:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

require 'spec_helper'

describe 'windows-installation-recipes::windows-tweaks' do
  context 'When all attributes are default, on an Ubuntu 16.04' do
    let(:chef_run) do
      # for a complete list of available platforms and versions see:
      # https://github.com/customink/fauxhai/blob/master/PLATFORMS.md
      runner = ChefSpec::ServerRunner.new(platform: 'ubuntu', version: '16.04')
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

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end
  end
end
