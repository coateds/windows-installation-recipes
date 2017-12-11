#
# Chef Documentation
# https://docs.chef.io/libraries.html
#

#
# This module name was auto-generated from the cookbook name. This name is a
# single word that starts with a capital letter and then continues to use
# camel-casing throughout the remainder of the name.
#
module WindowsInstallationRecipes
  module HelperHelpers
    #
    # Define the methods that you would like to assist the work you do in recipes,
    # resources, or templates.
    #
    # def my_helper_method
    #   # help method implementation
    # end
    # def ps_ver
    #   ps_psver_script = <<-EOH
    #   $var = $PSVersionTable.PSVersion.Major.ToString()+'.'+$PSVersionTable.PSVersion.Minor.ToString()
    #   If ($var -eq 5.1) {$True}
    #   Else {$False}
    #   EOH
    #   powershell_out(ps_psver_script).stdout.chop.to_s
    # end

    # A Function to return the PowerShell Version using PowerShell
    def ps_ver
      ps_psver_script = <<-EOH
      $PSVersionTable.PSVersion.Major.ToString()+'.'+$PSVersionTable.PSVersion.Minor.ToString()
      EOH
      powershell_out(ps_psver_script).stdout.chop.to_s
    end
  end
end

Chef::Recipe.send(:include, WindowsInstallationRecipes::HelperHelpers)

#
# The module you have defined may be extended within the recipe to grant the
# recipe the helper methods you define.
#
# Within your recipe you would write:
#
#     extend WindowsInstallationRecipes::HelperHelpers
#
#     my_helper_method
#
# You may also add this to a single resource within a recipe:
#
#     template '/etc/app.conf' do
#       extend WindowsInstallationRecipes::HelperHelpers
#       variables specific_key: my_helper_method
#     end
#
