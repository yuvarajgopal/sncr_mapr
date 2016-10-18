# # Cookbook Name:: sncr_mapr
# Recipe:: default
#
# Copyright 2015, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

# Parameter settings, user definitions, etc
include_recipe 'sncr_mapr::install_prereq_packages'
include_recipe 'sncr_mapr::clush'
include_recipe 'sncr_mapr::user_mapr'
# NO! include_recipe 'sncr_mapr::user_root'
include_recipe 'sncr_mapr::validate_host'
include_recipe 'sncr_mapr::ssh'
# include_recipe 'ntp'

# All cluster nodes need the following:
include_recipe 'sncr_mapr::mapr_base'
include_recipe 'sncr_mapr::mapr_nodemanager'

is_zk = 'no'
is_cldb = 'no'

# Install CLDB service from attributes
node['sncr_mapr']['cldb'].each do |cldb|
  if node['fqdn'] == cldb
    print "\nWill install CLDB on node: #{node['fqdn']}\n"
    is_cldb = 'yes'
    include_recipe 'sncr_mapr::mapr_cldb'
  end
end

# Install Zookeeper service from attributes
node['sncr_mapr']['zk'].each do |zk|
  if node['fqdn'] == zk
    print "\nWill install Zookeeper on node: #{node['fqdn']}\n"
    is_zk = 'yes'
    include_recipe 'sncr_mapr::mapr_zookeeper'
  end
end

# Install Resource Manager service from attributes
node['sncr_mapr']['rm'].each do |rm|
  if node['fqdn'] == rm
    print "\nWill install Resource Manager on node: #{node['fqdn']}\n"
    include_recipe 'sncr_mapr::mapr_resourcemanager'
  end
end

# Install YARN History Server service from attributes
if node['fqdn'] == node['sncr_mapr']['hs']
  print "\nWill install Yarn History Server  on node: #{node['fqdn']}\n"
  include_recipe 'sncr_mapr::mapr_historyserver'
end

# Install MapR Webserver service from attributes
node['sncr_mapr']['ws'].each do |ws|
  if node['fqdn'] == ws
    print "\nWill install MapR Webserver on node: #{node['fqdn']}\n"
    include_recipe 'sncr_mapr::mapr_webserver'
  end
end

# Set up environment variables, nfsserver automount,
# and run configure.sh to configure cluster.
# NOTE:
#   This will NOT automatically bring up the cluster.
#   That is done below...

include_recipe 'sncr_mapr::mapr_setenv'
include_recipe 'sncr_mapr::mapr_configure'
include_recipe 'sncr_mapr::_make_coresite_xml'

# Start Zookeeper service
if is_zk == 'yes'
  include_recipe 'sncr_mapr::mapr_start_zookeeper'
else
  execute 'sleep for zookeeper' do
    command 'sleep 60'
  end
end

# Start CLDB service
if is_cldb == 'yes'
  include_recipe 'sncr_mapr::mapr_start_warden'
else
  execute 'sleep for cldb' do
    command 'sleep 120'
  end
end

include_recipe 'sncr_mapr::mapr_start_warden' if is_cldb == 'no'

bash 'wait for warden' do
  code <<-EOH
    until service mapr-warden status | grep 'process' ; do
      echo  "waiting 10s for WARDEN to come up" | logger
      sleep 10
    done
  EOH
end

bash 'wait for CLDB' do
  code <<-EOH
    until maprcli node cldbmaster | grep 'ServerID'; do
      echo  "waiting 10s for CLDB to come up" | logger
      sleep 10
    done
  EOH
end

bash 'wait for all nodes to come up' do
  code <<-EOH
    while [ $( maprcli node list -columns hostname | \
                  grep -v "^hostname" | wc )
                  -lt #{node['sncr_mapr']['node_count']} ]; do
      sleep 20
    done
  EOH
end
