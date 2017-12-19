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

    def ps_net
      ps_net_script = <<-EOH
      Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter IPEnabled=TRUE -ComputerName . | Select-Object Description, DHCPEnabled, DHCPServer | ConvertTo-Html
      EOH
      powershell_out(ps_net_script).stdout.chop.to_s
    end

    def ps_service
      ps_service_script = <<-EOH
      Get-Service | Where-Object {($_.status -ne 'running') -and ($_.StartType -eq 'Automatic')} | Select-Object Status, Name, DisplayName, StartType | ConvertTo-Html
      EOH
      powershell_out(ps_service_script).stdout.chop.to_s
    end

    def ps_ntp
      ps_ntp_script = <<-EOH
      $NTPServer = '129.6.15.28'
      # Build NTP request packet. We'll reuse this variable for the response packet
      $NTPData    = New-Object byte[] 48  # Array of 48 bytes set to zero
      $NTPData[0] = 27                    # Request header: 00 = No Leap Warning; 011 = Version 3; 011 = Client Mode; 00011011 = 27

      # Open a connection to the NTP service
      $Socket = New-Object Net.Sockets.Socket ( 'InterNetwork', 'Dgram', 'Udp' )
      $Socket.SendTimeOut    = 2000  # ms
      $Socket.ReceiveTimeOut = 2000  # ms
      $Socket.Connect( $NTPServer, 123 )

      # Make the request
      $Null = $Socket.Send(    $NTPData )
      $Null = $Socket.Receive( $NTPData )

      # Clean up the connection
      $Socket.Shutdown( 'Both' )
      $Socket.Close()

      # Extract relevant portion of first date in result (Number of seconds since "Start of Epoch")
      $Seconds = [BitConverter]::ToUInt32( $NTPData[43..40], 0 )

      # Add them to the "Start of Epoch", convert to local time zone, and return
      $NTPTime = ([datetime]'1/1/1900' ).AddSeconds( $Seconds ).ToLocalTime()
      $SysTime = Get-Date
      $DiffTime = [math]::abs(($NTPTime - $SysTime).TotalSeconds)

      $obj = New-Object -TypeName PSObject
      Add-Member -InputObject $obj -MemberType NoteProperty -Name NTPTime -Value $NTPTime.ToString()
      Add-Member -InputObject $obj -MemberType NoteProperty -Name SYSTime -Value $SysTime.ToString()
      Add-Member -InputObject $obj -MemberType NoteProperty -Name DIFFTime -Value $DiffTime

      return $obj | ConvertTo-Json
      EOH
      powershell_out(ps_ntp_script).stdout.chop.to_s
    end

    def ps_lastupdate
      ps_lastupdate_script = <<-EOH
      (get-hotfix | sort installedon | select -last 1).InstalledOn
      EOH
      powershell_out(ps_lastupdate_script).stdout.chop.to_s
    end

    def ps_pingdomain(domain)
      ps_ping_domain = <<-EOH
      Test-Connection "#{domain}" -count 1 | Select-Object PSComputerName,Address,IPV4Address | ConvertTo-Html
      EOH
      powershell_out(ps_ping_domain).stdout.chop.to_s
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
