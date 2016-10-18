include_recipe 'build-essential'

log "\n=========== Start MapR install_mapr_prereqs.rb =============\n"

prereq_packages = node['sncr_mapr']['prereq']['packages']

prereq_packages.each do |pkg|
  package pkg
end

include_recipe 'java' if node['sncr_mapr']['manage_java']

include_recipe 'iptables::disabled'
include_recipe 'selinux::disabled'

service 'rpcbind' do
  action [:enable, :start]
end
