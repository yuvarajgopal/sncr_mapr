#
# Cookbook Name:: sncr_mapr
# Recipe:: _spark_common
#
# Copyright (c) 2016 Synchronoss Technologies, Inc., All Rights Reserved.

# some common _spark tasks

mapr_user    = node['sncr_mapr']['user']
mapr_group   = node['sncr_mapr']['group']
mapr_homedir = node['sncr_mapr']['home']

spark_homedir = "#{mapr_homedir}/spark/spark-current"
spark_conf    = "#{spark_homedir}/conf/spark-env.sh"

spark_daemon_memory = node['sncr_mapr']['spark_config']['daemon_memory']
spark_worker_memory = node['sncr_mapr']['spark_config']['worker_memory']

%w( mapr-spark ).each do |pkg|
  package pkg do
  end
end

bash "create symlink for #{spark_homedir}" do
  code <<-EOH
    ln -s #{mapr_homedir}/spark/spark-* #{spark_homedir}
  EOH
  not_if "test -r #{spark_homedir}"
end

spark_path = "#{spark_homedir}/bin"

template '/etc/profile.d/spark.sh' do
  source 'etc/profile.d/spark.sh.erb'
  owner 'root'
  group 'root'
  mode 00555
  variables({
              spark_path: spark_path
            })
end

template "/home/#{mapr_user}/.bashrc.d/spark.sh" do
  source 'etc/profile.d/spark.sh.erb'
  owner mapr_user
  group mapr_group
  mode 00644
  variables({
              spark_path: spark_path
            })
end

public_ip = "192.168.1.10"
private_ip = "192.168.0.22"
spark_public_dns = nil
cloud_platform = node['sncr_mapr']['cloudplatform']

unless public_ip.nil?
  if cloud_platform == 'aws'
    dashed_ip = public_ip.tr(/\./, '-')
    spark_public_dns = "ec2-#{dashed_ip}.compute-1.amazonaws.com"
  else
    spark_public_dns = private_ip
  end
end

template spark_conf do
  source 'spark/spark-env.sh.erb'
  owner mapr_user
  group mapr_user
  mode 0444
  variables({
              daemon_memory: spark_daemon_memory,
              worker_memory: spark_worker_memory,
              public_dns: spark_public_dns
            })
  notifies :run, 'bash[notify master to restart slave]'
end

spark_master = nil
master_count = 0
query = "roles:mapr_spark_master AND chef_environment:#{node.chef_environment}"
log "searching for the spark master with #{query}"

if Chef::Config[:solo]
  Chef::Log.warn('This recipe uses search. Chef Solo does not support search.')
else
  search(:node, query).each do |node|
    spark_master = node['hostname']
    master_count += 1
  end
end

# log "found master to be #{spark_master} count was #{master_count}"

bash 'notify master to restart slave' do
  code <<-EOH
   su #{mapr_user} -c "#{spark_homedir}/sbin/stop-slave.sh"
    sleep 10
    su #{mapr_user} -c "#{spark_homedir}/sbin/start-slave.sh spark://#{spark_master}:7077"
  EOH
  action :nothing
  ignore_failure true
  not_if { spark_master.nil? }
end
