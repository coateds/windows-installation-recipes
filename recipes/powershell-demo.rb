#
# Cookbook:: windows-installation-recipes
# Recipe:: powershell-demo
#
# Copyright:: 2017, The Authors, All Rights Reserved.

# In Attributes:
# default['powershell-demo']['beginphrase'] = 'Goodbye (Cruel)'

endphrase = 'World'

# It is possible to expand an attribute from within a PowerShell block (beginphrase)
# or expand a Ruby variable defined earlier in the script (endphrase)
# Both the dbl quotes and the #{...} sytaxes are required
ps_demo_script = <<-EOH
  $beginphrase = "#{node['powershell-demo']['beginphrase']}"
  $endphrase = "#{endphrase}"

  $beginphrase = $beginphrase.replace('Cruel', 'Cruela')
  $endphrase = $endphrase.replace('o', 'e')

  return $beginphrase + ' ' + $endphrase
EOH

# In this example, the modified output is simply concatenated into a single string
# It is possible to split the ps var below on the space (ps.split(' ')), but there
# appears to be another way.
# The .chop method removes nasty CrLf Chars
ps = powershell_out(ps_demo_script)
puts ps.stdout.chop.to_s

ps_demo_script1 = <<-EOH
  $beginphrase = "#{node['powershell-demo']['beginphrase']}"
  $endphrase = "#{endphrase}"

  $beginphrase = $beginphrase.replace('Cruel', 'Cruela')
  $endphrase = $endphrase.replace('o', 'e')

  $obj = New-Object -TypeName PSObject
  Add-Member -InputObject $obj -MemberType NoteProperty -Name beginphrase -Value $beginphrase
  Add-Member -InputObject $obj -MemberType NoteProperty -Name endphrase -Value $endphrase
  return $obj | ConvertTo-Json
EOH

# In this version, PowerShell converts a custom object to JSON format
# Ruby is then able to convert this to a hash
ps1 = powershell_out(ps_demo_script1)
node.default['obj'] = JSON.parse(ps1.stdout)

# The output of the hash can be consumed in Ruby...
puts node.default
# node['obj']['beginphrase']
# node['obj']['endphrase']

# ...or be used in an extended Ruby File
template 'c:/inetpub/wwwroot/ps-demo.htm' do
  source 'ps-demo.htm.erb'
end

# This would need a guard to actually use as a converge will fail if nothing to kill
# processtokill = "notepad"
#
# powershell_script 'kill-process' do
#   code "get-process -name #{processtokill} | stop-process"
# end

# Extended Ruby html file
# <html>
# <body>
#   <%= node['obj']['beginphrase'] %> <%= node['obj']['endphrase'] %>
# </html>
# </body>

# Stuart Preston Example
# ruby_block 'PSObject to Hash' do
#    block do
#      script = <<-EOH
#      $obj = New-Object -TypeName PSObject
#      Add-Member -InputObject $obj -MemberType NoteProperty -Name Property1 -Value "Grok This!"
#      Add-Member -InputObject $obj -MemberType NoteProperty -Name Property2 -Value "Forty Two"
#      return $obj | ConvertTo-Json
#      EOH
#
#      cmd = powershell_out(script)
#      node.default['obj'] = JSON.parse(cmd.stdout)
#
#      puts
#      puts node.default
#      puts node['obj']['Property1']
#      puts node['obj']['Property2']
#    end
#    action :run
#  end
