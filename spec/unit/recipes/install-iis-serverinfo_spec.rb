#
# Cookbook:: windows-installation-recipes
# Spec:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

require 'spec_helper'

describe 'windows-installation-recipes::install-iis-serverinfo' do
  context 'When all attributes are default, on an Ubuntu 16.04' do
    let(:chef_run) do
      # for a complete list of available platforms and versions see:
      # https://github.com/customink/fauxhai/blob/master/PLATFORMS.md
      runner = ChefSpec::ServerRunner.new(platform: 'ubuntu', version: '16.04')
      runner.converge(described_recipe)
    end

    it 'installs a feature' do
      expect(chef_run).to install_windows_feature('IIS-WebServerRole')
    end

    it 'service' do
      expect(chef_run).to enable_service('w3svc')
    end

    it 'service' do
      expect(chef_run).to start_service('w3svc')
    end

    it 'creates a template' do
      expect(chef_run).to create_template('c:\inetpub\wwwroot\default.htm')
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end
  end
end
