log "\n=========== Start MapR validate_host.rb =============\n"

mapr_version = node['sncr_mapr']['version']

gpgkey_url = node['sncr_mapr']['yum']['gpgkey_url']

include_recipe 'sysctl::default'

bash 'uname -m' do
  code <<-EOF
    uname -m
  EOF
end

execute 'validate_host_viable' do
  command 'uname -m'
  action :run
end

sysctl_param 'vm.swappiness' do
  value 0
end

sysctl_param 'net.ipv4.tcp_retries2' do
  value 5
end

sysctl_param 'vm.overcommit_memory' do
  value 0
end

%w( hard soft ).each do |ltype|
  set_limit 'mapr' do
    type ltype
    item 'nofile'
    value 64_000
  end

  set_limit 'mapr' do
    type ltype
    item 'nproc'
    value 64_000
  end
end

yum_repository 'maprtech' do
  description 'MapR Technologies'
  baseurl "http://package.mapr.com/releases/v#{mapr_version}/redhat"
  gpgcheck true
  gpgkey gpgkey_url
  action :create
end

major_version = mapr_version.sub(/([0-9]+)\..*$/, '\1')

yum_repository 'maprecosystem' do
  description 'MapR Technologies (ecosystem)'
  baseurl "http://package.mapr.com/releases/ecosystem-#{major_version}.x/redhat"
  gpgcheck false
  gpgkey gpgkey_url
  action :create
end
