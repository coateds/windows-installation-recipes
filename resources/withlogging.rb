# To learn more about Custom Resources, see https://docs.chef.io/custom_resources.html

property :dir, String
property :pkg, String

action :install do
  new_resource.pkg
end

action :mkdir do
  new_resource.dir
end
