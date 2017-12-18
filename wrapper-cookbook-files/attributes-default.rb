# hyperwindows (2012R2 & 2016)

#### Instructions ####
# It occurs to me that the attributes file is a good place for an instrunction set of sorts
# Ideally, all control of of the recipe should take place here
# Unfortunately, this is not exactly the case
# ['windows-tweaks']['new-computername'] can be used to determine if the client should be renamed
# and what the new name ought to be.
# However, the Integration test needs to be changed as I cannot figure out how to use an
# attribute in the default_test.rb file

#### Current Goal ####
# Make all recipes attribute driven
# All recipes will be included
# But nothing happens without an attribute set to 'y'

#### windows-tweaks ####
# Run general tweaks
default['windows-tweaks']['general-tweaks'] = 'n'

# Rename computer
# Leave this at no-new-name to do nothing
# Or set this to have a new name in ALL CAPS
# This is unecessary when working on Azure VMs as the anem can be set in
# the .kitchen.yml file
default['windows-tweaks']['new-computername']  = 'no-new-name'
# default['windows-tweaks']['new-computername']  = 'HYPERWINDOWS'

# The reboot notification attached to the rename is set to delayed
# This means it will reboot at the end if nothing else calls an immediate reboot
# for 2012R2, this will likely be the PS 5.1 install
#### /windows-tweaks ####

#### install-packages ####
# Basic will install Chocolatety
# Upgrade is largely going to be un-used for building VMs right now
# BuildBox 3 included an old version in the image
default['install-packages']['basic-chocolatey']   = 'n'
default['install-packages']['upgrade-chocolatey'] = 'n'

# PowerShell and modules
# More work and testing is likely needed to handle all (likely) scenarios
# Regarding what is installed and what needs to be upgraded
# Logic has been put in place to prevent this from running if PS5.1 is
# already been installed, such as with Server 2016
default['install-packages']['powershell51']       = 'n'
default['install-packages']['PSWindowsUpdate']    = 'n'

# Install Git with options
default['install-packages']['git']                = 'n'

# This install fails dependency DotNet4.5.2 on 2012R2 (DotNet4.5.2 fails to install cleanly)
# Works fine on 2016 (DotNet does not seem to be required)
default['install-packages']['vscode']             = 'n'

# The rest of these should be routine at this point
default['install-packages']['chefdk']             = 'n'

# When running this grouping on 2016, Putty & Curl OK, Sysinternals and poshgit did not run
default['install-packages']['putty']              = 'n'
default['install-packages']['curl']               = 'n'
default['install-packages']['sysinternals']       = 'n'
default['install-packages']['poshgit']            = 'n'

# Minimally tested
default['install-packages']['azstorexplorer']     = 'n'
default['install-packages']['pester']             = 'n'
default['install-packages']['rdcman']             = 'n'
default['install-packages']['slack']              = 'n'

# default['install-packages']['winazpowershell'].to_s == 'y'
    # chocolatey_package 'windowsazurepowershell' do
        #  windowsazurepowershell_0871
        # Appears to need a reboot still
        # This appears to be less usefull at this time?

# azure-cli

#### /install-packages ####

#### access-rdp ####
default['my_windows_rdp']['ConfigureRDP']         = 'n'

default['my_windows_rdp']['AllowConnections']  = 'yes'
default['my_windows_rdp']['AllowOnlyNLA']      = 'yes'
default['my_windows_rdp']['ConfigureFirewall'] = 'yes'
#### /access-rdp ####

#### install-iis-serverinfo ####
default['install-iis-serverinfo']['install-iis'] = 'n'
default['install-iis-serverinfo']['create-infopage'] = 'n'
default['install-iis-serverinfo']['infopage-path'] = 'c:\scripts'
#### /install-iis-serverinfo ####

#### powershell-demo ####
default['powershell-demo']['beginphrase'] = 'Goodbye (Cruel)'
#### /powershell-demo ####
