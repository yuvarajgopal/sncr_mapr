#
# Cookbook Name:: mapr
# Recipe:: clush (clustershell)
#
# Copyright 2013, MapR Technologies
#

log "\n=========== Start MapR clush.rb =============\n"

clustershell_rpm_url = node['sncr_mapr']['clustershell']['rpm_url']

all = node['sncr_mapr']['cluster_nodes'].reject(&:empty?).join(',')
cldb_nodes = node['sncr_mapr']['cldb'].reject(&:empty?).join(',')
zk_nodes = node['sncr_mapr']['zk'].reject(&:empty?).join(',')
rm_nodes = node['sncr_mapr']['rm'].reject(&:empty?).join(',')
ws_nodes = node['sncr_mapr']['ws'].reject(&:empty?).join(',')
hs_server = node['sncr_mapr']['hs']

bash 'install lush' do
  code <<-EOH
    rpm -ivh #{clustershell_rpm_url}
  EOH
  not_if 'rpm -qa | grep clustershell'
end

# i can not get the package resource to work from the github url [SGC]
# package 'clustershell' do
#   source clustershell_rpm_url
# end

directory '/etc/clustershell' do
  owner 'root'
  group 'root'
  mode 00755
  action :create
end

# groups file
template '/etc/clustershell/groups' do
  source 'clustershell.groups.erb'
  variables({
              :all => all,
              :cldb => cldb_nodes,
              :zk => zk_nodes,
              :rm => rm_nodes,
              :ws => ws_nodes,
              :hs => hs_server
            })
  mode 00644
end
