name 'windows-installation-recipes'
maintainer 'The Authors'
maintainer_email 'you@example.com'
license 'All Rights Reserved'
description 'Installs/Configures windows-installation-recipes'
long_description 'Installs/Configures windows-installation-recipes'
version '0.3.1'
chef_version '>= 12.1' if respond_to?(:chef_version)

# Versions
# 0.3.0
# First to be used on Hosted Chef

# 0.3.1
# Adds Choco list -l to info html file

# The `issues_url` points to the location where issues for this cookbook are
# tracked.  A `View Issues` link will be displayed on this cookbook's page when
# uploaded to a Supermarket.
#
# issues_url 'https://github.com/<insert_org_here>/windows-installation-recipes/issues'

# The `source_url` points to the development repository for this cookbook.  A
# `View Source` link will be displayed on this cookbook's page when uploaded to
# a Supermarket.
#
# source_url 'https://github.com/<insert_org_here>/windows-installation-recipes'

depends 'chocolatey'
depends 'windows_ad'
